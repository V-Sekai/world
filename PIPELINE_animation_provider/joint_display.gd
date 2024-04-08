@tool
extends Node3D


const Axis3Scene : PackedScene = preload("res://helpers/axis_3.tscn")


var _reader : AxisStudioReader

var _targets : Array[Node3D] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	# Construct the reader
	_reader = AxisStudioReader.new()
	_reader.listen()

	# Construct the targets
	for index in Joint.JOINT_COUNT:
		var axis : Node3D = Axis3Scene.instantiate()
		_targets.append(axis)
		add_child(axis)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _reader.read():
		return

	var joints := _reader.get_joints()
	for index in Joint.JOINT_COUNT:
		if joints[index].valid:
			_targets[index].position = joints[index].position
			_targets[index].basis = Basis(joints[index].rotation)
