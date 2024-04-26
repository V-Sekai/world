extends RigidBody2D


func _ready() -> void:
	sleeping_state_changed.connect(_on_sleep)


func _on_sleep():
	if sleeping:
		await get_tree().physics_frame
		freeze = true
