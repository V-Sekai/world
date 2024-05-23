extends TextureButton

@export var modulate_on : Color
@export var modulate_off : Color

func _ready():
	button_pressed = get_window().always_on_top
	self_modulate = modulate_on if button_pressed else modulate_off
	toggled.connect(_on_toggled)

func _on_toggled(val):
	self_modulate = modulate_on if val else modulate_off
	get_window().always_on_top = val
