�]
��
8
Const
output"dtype"
valuetensor"
dtypetype

NoOp
�
PartitionedCall
args2Tin
output2Tout"
Tin
list(type)("
Tout
list(type)("	
ffunc"
configstring "
config_protostring "
executor_typestring 
C
Placeholder
output"dtype"
dtypetype"
shapeshape:
@
ReadVariableOp
resource
value"dtype"
dtypetype�
�
StatefulPartitionedCall
args2Tin
output2Tout"
Tin
list(type)("
Tout
list(type)("	
ffunc"
configstring "
config_protostring "
executor_typestring �
q
VarHandleOp
resource"
	containerstring "
shared_namestring "
dtypetype"
shapeshape�"serve*2.0.02v2.0.0-rc2-26-g64c3d388�N
p
VariableVarHandleOp*
shape:*
shared_name
Variable*
dtype0*
_output_shapes
: 
i
Variable/Read/ReadVariableOpReadVariableOpVariable*
dtype0*"
_output_shapes
:

NoOpNoOp
�
ConstConst"/device:CPU:0*�
value{By Bs
1
v

signatures
trt_engine_resources
:8
VARIABLE_VALUEVariablev/.ATTRIBUTES/VARIABLE_VALUE
 
 *
dtype0*
_output_shapes
: 
�
serving_default_input1Placeholder*
dtype0*+
_output_shapes
:���������* 
shape:���������
�
serving_default_input2Placeholder*
dtype0*+
_output_shapes
:���������* 
shape:���������
�
PartitionedCallPartitionedCallserving_default_input1serving_default_input2**
_gradient_op_typePartitionedCall-270**
f%R#
!__inference_signature_wrapper_261*
Tout
2*/
config_proto

GPU

CPU2*0,1J 8*
_output_shapes
:*
Tin
2
O
saver_filenamePlaceholder*
dtype0*
_output_shapes
: *
shape: 
�
StatefulPartitionedCallStatefulPartitionedCallsaver_filenameVariable/Read/ReadVariableOpConst*%
f R
__inference__traced_save_292*
Tout
2*/
config_proto

GPU

CPU2*0,1J 8*
Tin
2*
_output_shapes
: **
_gradient_op_typePartitionedCall-293
�
StatefulPartitionedCall_1StatefulPartitionedCallsaver_filenameVariable**
_gradient_op_typePartitionedCall-309*(
f#R!
__inference__traced_restore_308*
Tout
2*/
config_proto

GPU

CPU2*0,1J 8*
Tin
2*
_output_shapes
: �A
�
I
!__inference_signature_wrapper_261

input1

input2
identity�
PartitionedCallPartitionedCallinput1input2*/
config_proto

GPU

CPU2*0,1J 8*
_output_shapes
:*
Tin
2**
_gradient_op_typePartitionedCall-258*
fR
__inference_pruned_251*
Tout
2Q
IdentityIdentityPartitionedCall:output:0*
_output_shapes
:*
T0"
identityIdentity:output:0*A
_input_shapes0
.:���������:���������:&"
 
_user_specified_nameinput2:& "
 
_user_specified_nameinput1
�

d
TRTEngineOp_0_native_segment
tensorrtinputph_0
tensorrtinputph_1
tensorrtoutputph_0c
*StatefulPartitionedCall/add/ReadVariableOpConst*!
valueB"  �?*
dtype0M
%Func/StatefulPartitionedCall/input/_1Identitytensorrtinputph_0*
T0M
%Func/StatefulPartitionedCall/input/_2Identitytensorrtinputph_1*
T0�
StatefulPartitionedCall/addAddV2.Func/StatefulPartitionedCall/input/_1:output:03StatefulPartitionedCall/add/ReadVariableOp:output:0*
T0|
StatefulPartitionedCall/mulMul.Func/StatefulPartitionedCall/input/_1:output:0StatefulPartitionedCall/add:z:0*
T0q
StatefulPartitionedCall/add_1AddV2StatefulPartitionedCall/mul:z:0StatefulPartitionedCall/add:z:0*
T0�
StatefulPartitionedCall/add_2AddV2!StatefulPartitionedCall/add_1:z:0.Func/StatefulPartitionedCall/input/_2:output:0*
T0V
StatefulPartitionedCall/outputIdentity!StatefulPartitionedCall/add_2:z:0*
T0�
 StatefulPartitionedCall/IdentityIdentity'StatefulPartitionedCall/output:output:0+^StatefulPartitionedCall/add/ReadVariableOp*
T0f
&Func/StatefulPartitionedCall/output/_4Identity)StatefulPartitionedCall/Identity:output:0*
T0"E
tensorrtoutputph_0/Func/StatefulPartitionedCall/output/_4:output:0*!
experimental_ints_on_device(
�
�
__inference__traced_save_292
file_prefix'
#savev2_variable_read_readvariableop
savev2_1_const

identity_1��MergeV2Checkpoints�SaveV2�SaveV2_1�
StringJoin/inputs_1Const"/device:CPU:0*<
value3B1 B+_temp_cbae79dc2e56439298f39e62d2f3c723/part*
dtype0*
_output_shapes
: s

StringJoin
StringJoinfile_prefixStringJoin/inputs_1:output:0"/device:CPU:0*
N*
_output_shapes
: L

num_shardsConst*
value	B :*
dtype0*
_output_shapes
: f
ShardedFilename/shardConst"/device:CPU:0*
value	B : *
dtype0*
_output_shapes
: �
ShardedFilenameShardedFilenameStringJoin:output:0ShardedFilename/shard:output:0num_shards:output:0"/device:CPU:0*
_output_shapes
: �
SaveV2/tensor_namesConst"/device:CPU:0*1
value(B&Bv/.ATTRIBUTES/VARIABLE_VALUE*
dtype0*
_output_shapes
:o
SaveV2/shape_and_slicesConst"/device:CPU:0*
valueB
B *
dtype0*
_output_shapes
:�
SaveV2SaveV2ShardedFilename:filename:0SaveV2/tensor_names:output:0 SaveV2/shape_and_slices:output:0#savev2_variable_read_readvariableop"/device:CPU:0*
_output_shapes
 *
dtypes
2h
ShardedFilename_1/shardConst"/device:CPU:0*
value	B :*
dtype0*
_output_shapes
: �
ShardedFilename_1ShardedFilenameStringJoin:output:0 ShardedFilename_1/shard:output:0num_shards:output:0"/device:CPU:0*
_output_shapes
: �
SaveV2_1/tensor_namesConst"/device:CPU:0*1
value(B&B_CHECKPOINTABLE_OBJECT_GRAPH*
dtype0*
_output_shapes
:q
SaveV2_1/shape_and_slicesConst"/device:CPU:0*
valueB
B *
dtype0*
_output_shapes
:�
SaveV2_1SaveV2ShardedFilename_1:filename:0SaveV2_1/tensor_names:output:0"SaveV2_1/shape_and_slices:output:0savev2_1_const^SaveV2"/device:CPU:0*
_output_shapes
 *
dtypes
2�
&MergeV2Checkpoints/checkpoint_prefixesPackShardedFilename:filename:0ShardedFilename_1:filename:0^SaveV2	^SaveV2_1"/device:CPU:0*
T0*
N*
_output_shapes
:�
MergeV2CheckpointsMergeV2Checkpoints/MergeV2Checkpoints/checkpoint_prefixes:output:0file_prefix	^SaveV2_1"/device:CPU:0*
_output_shapes
 f
IdentityIdentityfile_prefix^MergeV2Checkpoints"/device:CPU:0*
T0*
_output_shapes
: s

Identity_1IdentityIdentity:output:0^MergeV2Checkpoints^SaveV2	^SaveV2_1*
_output_shapes
: *
T0"!

identity_1Identity_1:output:0*%
_input_shapes
: :: 2
SaveV2_1SaveV2_12
SaveV2SaveV22(
MergeV2CheckpointsMergeV2Checkpoints:+ '
%
_user_specified_namefile_prefix: : 
�
�
__inference__traced_restore_308
file_prefix
assignvariableop_variable

identity_2��AssignVariableOp�	RestoreV2�RestoreV2_1�
RestoreV2/tensor_namesConst"/device:CPU:0*1
value(B&Bv/.ATTRIBUTES/VARIABLE_VALUE*
dtype0*
_output_shapes
:r
RestoreV2/shape_and_slicesConst"/device:CPU:0*
valueB
B *
dtype0*
_output_shapes
:�
	RestoreV2	RestoreV2file_prefixRestoreV2/tensor_names:output:0#RestoreV2/shape_and_slices:output:0"/device:CPU:0*
dtypes
2*
_output_shapes
:L
IdentityIdentityRestoreV2:tensors:0*
_output_shapes
:*
T0u
AssignVariableOpAssignVariableOpassignvariableop_variableIdentity:output:0*
dtype0*
_output_shapes
 �
RestoreV2_1/tensor_namesConst"/device:CPU:0*1
value(B&B_CHECKPOINTABLE_OBJECT_GRAPH*
dtype0*
_output_shapes
:t
RestoreV2_1/shape_and_slicesConst"/device:CPU:0*
valueB
B *
dtype0*
_output_shapes
:�
RestoreV2_1	RestoreV2file_prefix!RestoreV2_1/tensor_names:output:0%RestoreV2_1/shape_and_slices:output:0
^RestoreV2"/device:CPU:0*
dtypes
2*
_output_shapes
:1
NoOpNoOp"/device:CPU:0*
_output_shapes
 m

Identity_1Identityfile_prefix^AssignVariableOp^NoOp"/device:CPU:0*
_output_shapes
: *
T0y

Identity_2IdentityIdentity_1:output:0^AssignVariableOp
^RestoreV2^RestoreV2_1*
_output_shapes
: *
T0"!

identity_2Identity_2:output:0*
_input_shapes
: :2$
AssignVariableOpAssignVariableOp2
	RestoreV2	RestoreV22
RestoreV2_1RestoreV2_1: :+ '
%
_user_specified_namefile_prefix
�
>
__inference_pruned_251

input1

input2
identity{
statefulpartitionedcall_args_2Const*!
valueB*  �?*
dtype0*"
_output_shapes
:�
2Func/StatefulPartitionedCall/input_control_node/_0NoOp^input1^input2^statefulpartitionedcall_args_2*
_output_shapes
 �
TRTEngineOp_0TRTEngineOpinput1input23^Func/StatefulPartitionedCall/input_control_node/_0*
static_engine( *
serialized_segment *
InT
2*
workspace_size_bytes����*0
segment_func R
TRTEngineOp_0_native_segment*
_output_shapes
:*
use_calibration( *
precision_modeFP32*
OutT
2a
3Func/StatefulPartitionedCall/output_control_node/_5NoOp^TRTEngineOp_0*
_output_shapes
 �
IdentityIdentityTRTEngineOp_0:out_tensor:04^Func/StatefulPartitionedCall/output_control_node/_5*
T0*
_output_shapes
:"
identityIdentity:output:0*A
_input_shapes0
.:���������:���������:  : 
�
t
__inference_run_173

input1

input2
add_readvariableop_resource
identity��add/ReadVariableOp�
add/ReadVariableOpReadVariableOpadd_readvariableop_resource",/job:localhost/replica:0/task:0/device:GPU:0*
dtype0*"
_output_shapes
:f
addAddV2input1add/ReadVariableOp:value:0*
T0*+
_output_shapes
:���������Q
mulMulinput1add:z:0*
T0*+
_output_shapes
:���������V
add_1AddV2mul:z:0add:z:0*
T0*+
_output_shapes
:���������W
add_2AddV2	add_1:z:0input2*
T0*+
_output_shapes
:���������S
outputIdentity	add_2:z:0*
T0*+
_output_shapes
:���������p
IdentityIdentityoutput:output:0^add/ReadVariableOp*+
_output_shapes
:���������*
T0"
identityIdentity:output:0*E
_input_shapes4
2:���������:���������:2(
add/ReadVariableOpadd/ReadVariableOp:& "
 
_user_specified_nameinput1:&"
 
_user_specified_nameinput2: "wJ
saver_filename:0StatefulPartitionedCall:0StatefulPartitionedCall_18"
saved_model_main_op

NoOp*�
serving_default�
=
input13
serving_default_input1:0���������
=
input23
serving_default_input2:0���������%
output_0
PartitionedCall:0tensorflow/serving/predict*>
__saved_model_init_op%#
__saved_model_init_op

NoOp:�
X
v

signatures
trt_engine_resources
run"
_generic_user_object
:2Variable
,
serving_default"
signature_map
 "
trackable_dict_wrapper
�2�
__inference_run_173�
���
FullArgSpec
args�
jinput1
jinput2
varargs
 
varkw
 
defaults
 

kwonlyargs� 
kwonlydefaults
 
annotations� *?�<
����������
����������
5B3
!__inference_signature_wrapper_261input1input2�
!__inference_signature_wrapper_261�m�j
� 
c�`
.
input1$�!
input1���������
.
input2$�!
input2���������"$�!

output_0�
output_0�
__inference_run_173|Y�V
O�L
$�!
input1���������
$�!
input2���������
� "����������