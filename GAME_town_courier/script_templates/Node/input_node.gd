# meta-description: Base template for Node with default Godot cycle methods
# meta-default: true

extends _BASE_

@onready var focus := SnailInput.get_input_focus(self)

func _physics_process(_delta: float) -> void:
	var input := focus.get_player_input()
