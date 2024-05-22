extends Control
class_name SceneTransition

@export var transition_length := 0.0
@export var animation: AnimationPlayer

signal finished


func _on_finished():
	finished.emit()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 32
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if animation:
		var anims := animation.get_animation_list()
		if anims.has("RESET"):
			anims.remove_at(anims.find("RESET"))
		if not anims.is_empty():
			animation.play(anims[0])
			animation.animation_finished.connect(_on_finished.unbind(1))
	else:
		_on_finished()


func hurry():
	if animation:
		animation.speed_scale = 4
