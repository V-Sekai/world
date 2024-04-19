extends Control

@onready var focus := SnailInput.get_input_focus(self)
@export_file("*.tscn") var next_scene_path: String

@onready var animation: AnimationPlayer = find_child("AnimationPlayer")
@onready var next_scene_is_valid = (next_scene_path) # and FileAccess.file_exists(next_scene_path))

var transition_out := false
@onready var editor_skip := OS.has_feature("editor") and _is_first_load()

func _is_first_load() -> bool:
	if $"/root".has_node("Globals"):
		return $"/root".get_node("Globals").first_load
	return true

func _clear_first_load():
	if $"/root".has_node("Globals"):
		$"/root".get_node("Globals").first_load = false

func _ready() -> void:
	assert(animation)
	var anims := animation.get_animation_list()
	if anims.has("RESET"):
		anims.remove_at(anims.find("RESET"))
	if not anims.is_empty() and not editor_skip:
		animation.play(anims[0])
		animation.animation_finished.connect(_on_animation_finish)
	if next_scene_is_valid:
		ResourceLoader.load_threaded_request(next_scene_path)

func _on_animation_finish(animation_name: StringName):
	if transition_out:
		return

	transition_out = true
	if next_scene_is_valid:
		if editor_skip:
			SnailTransition.auto_transition(ResourceLoader.load_threaded_get(next_scene_path), null)
		else:
			SnailTransition.auto_transition(ResourceLoader.load_threaded_get(next_scene_path))
	else:
		animation.queue(animation_name)
		transition_out = false
	_clear_first_load()

func _physics_process(_delta: float) -> void:
	if transition_out:
		return

	var spinner := %spinner as TextureRect
	spinner.pivot_offset = spinner.size / 2
	spinner.rotation += _delta * 4
	spinner.rotation = fmod(spinner.rotation, TAU)

	var status := ResourceLoader.load_threaded_get_status(next_scene_path, [])
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var t := spinner.create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_CUBIC)
		t.tween_property(spinner, "modulate:a", 0, 0.5)
		if editor_skip:
			_on_animation_finish(animation.current_animation)

	var input := focus.get_player_input()
	if input.is_anything_just_pressed():
		_on_animation_finish(animation.current_animation)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
