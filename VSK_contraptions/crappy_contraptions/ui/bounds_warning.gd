extends Area3D


func _ready() -> void:
	$Control.hide()

	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


func _on_enter(node: Node3D):
	if node is CharacterBody3D:
		$Control.hide()


func _on_exit(node: Node3D):
	if node is CharacterBody3D:
		$Control.show()
