extends Control

@export_file("*.tscn") var play_scene_path
@export_file("*.tscn") var sandbox_scene_path
@export var prev_scene: PackedScene
@onready var focus := SnailInput.get_input_focus(self)

func _physics_process(_delta: float) -> void:
	var input := focus.get_player_input()

	if prev_scene and input.is_action_just_pressed("ui_cancel"):
		SnailTransition.auto_transition(prev_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1 and %dev and %dev.visible:
			Globals.set_flag("level_1")
			Globals.set_flag("sandbox")

func _ready():
	if %continue.disabled:
		%play.grab_focus()
	else:
		%continue.grab_focus()
	%continue.pressed.connect(_on_continue)
	%play.pressed.connect(_on_play)
	%sandbox.pressed.connect(_on_sandbox)
	%clear.pressed.connect(_on_delete)
	%qtd.pressed.connect(_on_quit)
	%version.text = "v" + ProjectSettings.get_setting("application/config/version", "DEV")

	if not OS.has_feature("editor"):
		%dev.hide()

const ALL_MAPS := {
	"level_1": "res://game/level_1.tscn",
	"level_2": "res://game/level_2.tscn",
	"level_3": "res://game/level_3.tscn",
	"level_4": "res://game/level_4.tscn",
	"level_5": "res://game/level_5.tscn",
	"level_6": "res://game/level_6.tscn",
	"level_7": "res://game/level_7.tscn",
	"level_8": "res://game/level_8.tscn",
	"level_9": "res://game/level_9.tscn",
	"sandbox": "res://game/sandbox.tscn",
}

func _on_continue():
	var continue_map = Globals.flags["continue"]
	if ALL_MAPS.has(continue_map):
		SnailTransition.auto_transition_threaded(ALL_MAPS[continue_map])
	else:
		print("invalid continue map: %s" % continue_map)

func _on_sandbox():
	SnailTransition.auto_transition_threaded(sandbox_scene_path)

func _on_play():
	SnailTransition.auto_transition_threaded(play_scene_path)

func _on_delete():
	Globals.clear_save()
	SnailTransition.auto_transition_threaded(scene_file_path)

func _on_quit():
	SnailTransition.quit_after_transition_out = true
	SnailTransition.auto_transition(null)
