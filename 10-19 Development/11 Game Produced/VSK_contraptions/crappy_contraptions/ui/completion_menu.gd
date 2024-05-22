extends Control

@export_file("*.tscn") var sandbox_scene_path
@export_file("*.tscn") var quit_scene_path
@onready var focus := SnailInput.get_input_focus(self)


func _physics_process(_delta: float) -> void:
	var input := focus.get_player_input()

	if input.is_action_just_pressed("ui_cancel"):
		SnailTransition.auto_transition_threaded(quit_scene_path)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready():
	assert(sandbox_scene_path)
	assert(quit_scene_path)
	$sandbox.grab_focus()
	$sandbox.pressed.connect(_on_play)
	$quit.pressed.connect(_on_quit)


func _on_play():
	SnailTransition.auto_transition_threaded(sandbox_scene_path)


func _on_quit():
	SnailTransition.auto_transition_threaded(quit_scene_path)
