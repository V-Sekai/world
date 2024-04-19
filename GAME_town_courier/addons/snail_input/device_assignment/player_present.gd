extends Control

@export_enum("Keyboard", "Mouse", "Gamepad") var device_type := "Keyboard"

@export var keyboard_icon: Texture2D
@export var mouse_icon: Texture2D
@export var gamepad_icon: Texture2D

var label := "Keyboard"

func _ready() -> void:
	match device_type:
		"Keyboard":
			if keyboard_icon:
				$NinePatchRect/icon.texture = keyboard_icon
		"Mouse":
			if mouse_icon:
				$NinePatchRect/icon.texture = mouse_icon
		"Gamepad":
			if gamepad_icon:
				$NinePatchRect/icon.texture = gamepad_icon
	$NinePatchRect/label.text = label
