extends Resource
class_name BuildConnection

@export var node_a: NodePath
@export var node_b: NodePath


func _init(_node_a: NodePath = "", _node_b: NodePath = ""):
	node_a = _node_a
	node_b = _node_b
