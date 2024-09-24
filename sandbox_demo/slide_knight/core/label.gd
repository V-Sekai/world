extends Label

@export var player_elf : Sandbox_SlideKnightCorePlayerPlayer

func _ready() -> void:
	self.text = player_elf.get("player_name")

func _process(_delta: float) -> void:
	if self.name == "CallLabel":
		# Get any sandbox, and ask for the global number of VM calls made
		var total_calls = player_elf.get("global_calls_made")
		self.text = "Virtual Machine\nfunction calls: " + str(total_calls)
