extends Area3D
class_name SceneChangeTrigger

@export_file("*.tscn") var scene_path: String

@export var transition_out: PackedScene = SnailTransition.FADE_OUT
@export var transition_in: PackedScene = SnailTransition.FADE_IN

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(node: Node3D):
	if node is CharacterBody3D:
		SnailTransition.auto_transition_threaded(scene_path, transition_out, transition_in)
		body_entered.disconnect(_on_body_entered)
