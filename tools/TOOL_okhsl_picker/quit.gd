extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().quit()
