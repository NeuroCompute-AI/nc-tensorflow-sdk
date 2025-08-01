/* Copyright 2023 The OpenXLA Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/
#include "xla/backends/gpu/codegen/fusion_emitter.h"

#include <cstddef>
#include <string>
#include <vector>

#include "absl/log/check.h"
#include "absl/log/log.h"
#include "absl/status/status.h"
#include "absl/strings/str_cat.h"
#include "absl/strings/str_join.h"
#include "absl/types/span.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Type.h"
#include "llvm/TargetParser/Triple.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/AffineExpr.h"
#include "mlir/IR/AffineMap.h"
#include "xla/codegen/emitters/kernel_api_builder.h"
#include "xla/codegen/emitters/kernel_arguments.h"
#include "xla/hlo/analysis/indexing_map.h"
#include "xla/runtime/work_dimensions.h"
#include "xla/service/gpu/ir_emitter_context.h"
#include "xla/service/gpu/launch_dimensions.h"
#include "xla/service/gpu/target_util.h"
#include "xla/service/llvm_ir/llvm_util.h"
#include "xla/shape.h"
#include "xla/status_macros.h"
#include "xla/stream_executor/device_description.h"
#include "xla/tsl/platform/errors.h"

namespace xla {
namespace gpu {

// Annotates the launch dimensions of the corresponding IR kernel in
// `llvm_module`.
absl::Status AnnotateKernelLaunchDimensions(
    const se::DeviceDescription& device_info,
    const LaunchDimensions& launch_dims, llvm::Function* kernel,
    llvm::Module* llvm_module) {
  TF_RET_CHECK(
      (device_info.block_dim_limit().x == 0 ||
       launch_dims.block_counts().x < device_info.block_dim_limit().x) &&
      (device_info.block_dim_limit().y == 0 ||
       launch_dims.block_counts().y < device_info.block_dim_limit().y))
      << "Kernel '" << kernel->getName().str() << "' launch needs more blocks ("
      << launch_dims.block_counts().x << ", " << launch_dims.block_counts().y
      << ") than allowed by hardware (" << device_info.block_dim_limit().x
      << ", " << device_info.block_dim_limit().y << ").";
  // Add __launch_bounds__ to metadata. This limits registers per thread to
  // avoid out-of-resources launching errors.

  llvm::Triple target_triple = llvm::Triple(llvm_module->getTargetTriple());

  if (target_triple.isNVPTX()) {
    // Our launch bounds are exact, so we can specify them as
    // reqntid[xyz] rather than maxntid[xyz].
    const std::string attr =
        absl::StrCat(launch_dims.thread_counts_per_block().x, ",",
                     launch_dims.thread_counts_per_block().y, ",",
                     launch_dims.thread_counts_per_block().z);
    kernel->addFnAttr("nvvm.reqntid", attr);
    // Maybe we want to set "reqnctapercluster" here, but not sure if needed or
    // if LLVM supports that yet. Let's do that later when needed.
  } else if (target_triple.getArch() == llvm::Triple::amdgcn) {
    kernel->addFnAttr("amdgpu-flat-work-group-size",
                      absl::StrJoin({launch_dims.num_threads_per_block(),
                                     launch_dims.num_threads_per_block()},
                                    ","));
    kernel->addFnAttr("amdgpu-max-num-workgroups",
                      absl::StrJoin({launch_dims.block_counts().x,
                                     launch_dims.block_counts().y,
                                     launch_dims.block_counts().z},
                                    ","));
  }
  return absl::OkStatus();
}

IndexingMap KernelFusionInterface::GetDefaultThreadIdIndexingMap(
    const LaunchDimensions& launch_dims, int unroll_factor, const Shape& shape,
    mlir::MLIRContext* ctx) {
  WorkDimensions work_dimensions = launch_dims.AsWorkDimensions();
  work_dimensions.work_tile_size.dimensions.push_back(unroll_factor);
  return emitters::GetDefaultWorkItemIndexingMap(work_dimensions, shape, ctx);
}

std::string GetSanitizedUniqueName(IrEmitterContext& ir_emitter_context,
                                   const std::string& suggested_name) {
  return ir_emitter_context.name_uniquer()->GetUniqueName(
      llvm_ir::SanitizeFunctionName(suggested_name));
}

absl::StatusOr<llvm::Function*> BuildKernelPrototype(
    IrEmitterContext& ir_emitter_context, const std::string& impl_fn_name,
    const std::string& suggested_name,
    absl::Span<const emitters::KernelArgument> arguments,
    const LaunchDimensions& launch_dimensions, llvm::IRBuilderBase* builder) {
  return BuildKernelPrototypeFromUniqueName(
      ir_emitter_context, impl_fn_name,
      GetSanitizedUniqueName(ir_emitter_context, suggested_name), arguments,
      launch_dimensions, builder);
}

absl::StatusOr<llvm::Function*> BuildKernelPrototypeFromUniqueName(
    IrEmitterContext& ir_emitter_context, const std::string& impl_fn_name,
    const std::string& unique_kernel_name,
    absl::Span<const emitters::KernelArgument> arguments,
    const LaunchDimensions& launch_dimensions, llvm::IRBuilderBase* builder) {
  // Create the kernel and add it to the module.
  auto* llvm_module = ir_emitter_context.llvm_module();
  llvm::LLVMContext& context = llvm_module->getContext();
  // Explicitly set global addrspace for SPIR backend.
  int addrspace = llvm::Triple(llvm_module->getTargetTriple()).isSPIR() ? 1 : 0;
  llvm::FunctionType* kernel_type = llvm::FunctionType::get(
      /*Result=*/llvm::Type::getVoidTy(context),
      std::vector<llvm::Type*>(arguments.size(), builder->getPtrTy(addrspace)),
      /*isVarArg=*/false);
  llvm::Function* kernel =
      llvm::Function::Create(kernel_type, llvm::GlobalValue::ExternalLinkage,
                             unique_kernel_name, llvm_module);

  AnnotateFunctionAsGpuKernel(llvm_module, kernel, builder);
  TF_RETURN_IF_ERROR(
      AnnotateKernelLaunchDimensions(ir_emitter_context.gpu_device_info(),
                                     launch_dimensions, kernel, llvm_module));

  // Update the insert point to the entry basic block.
  llvm::BasicBlock* entry_bb =
      llvm::BasicBlock::Create(context, /*Name=*/"entry", /*Parent=*/kernel);

  // Emit a "return void" at entry_bb's end, and set the insert point before
  // that return instruction.
  builder->SetInsertPoint(llvm::ReturnInst::Create(context, entry_bb));
  // Get the original function to extract attributes.
  auto impl_func = llvm_module->getFunction(impl_fn_name);

  for (size_t arg_idx = 0; arg_idx < arguments.size(); ++arg_idx) {
    const emitters::KernelArgument& kernel_argument = arguments[arg_idx];
    // Get the original argument to extract attributes from if they exist.
    llvm::Argument* impl_arg = impl_func ? impl_func->getArg(arg_idx) : nullptr;
    llvm::Argument& llvm_arg = *kernel->getArg(arg_idx);
    llvm_arg.setName(absl::StrCat("arg", arg_idx));

    if (impl_arg && impl_arg->hasByValAttr()) {
      kernel->addParamAttr(arg_idx,
                           impl_arg->getAttribute(llvm::Attribute::ByVal));
    } else {
      kernel->addDereferenceableParamAttr(arg_idx,
                                          kernel_argument.slice().size());
    }
    // If the alignment has been specified in the original function, use it.
    // Otherwise, use the alignment from the kernel argument.
    if (impl_arg && impl_arg->hasAttribute(llvm::Attribute::Alignment)) {
      kernel->addParamAttr(arg_idx,
                           impl_arg->getAttribute(llvm::Attribute::Alignment));
    } else {
      kernel->addParamAttr(arg_idx,
                           llvm::Attribute::get(llvm_arg.getContext(),
                                                llvm::Attribute::Alignment,
                                                kernel_argument.alignment()));
    }
    if (!kernel_argument.aliased()) {
      kernel->addParamAttr(arg_idx,
                           llvm::Attribute::get(llvm_arg.getContext(),
                                                llvm::Attribute::NoAlias));
    }
  }

  return kernel;
}

}  // namespace gpu
}  // namespace xla
