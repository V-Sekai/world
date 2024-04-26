extends VBoxContainer

@onready var focus := SnailInput.get_input_focus(self)

@export var close_target: Node = self
@export_file("*.tscn") var restart_scene
@export_file("*.tscn") var menu_scene

func _ready():
	assert(close_target)
	$continue.grab_focus()
	$continue.pressed.connect(_on_continue)
	$restart.pressed.connect(_on_restart)
	$quit.pressed.connect(_on_quit)

func dismiss():
	await get_tree().process_frame
	get_tree().paused = false
	close_target.queue_free()

func _on_continue():
	dismiss()

func _on_restart():
	if restart_scene:
		get_tree().paused = false
		SnailTransition.auto_transition_threaded(restart_scene)

func _on_quit():
	if restart_scene:
		get_tree().paused = false
		SnailTransition.auto_transition_threaded(menu_scene)

func _input(event: InputEvent) -> void:
	var input := focus.get_player_input()
	if input.is_action_pressed("ui_cancel") and event.is_pressed():
		dismiss()

	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
