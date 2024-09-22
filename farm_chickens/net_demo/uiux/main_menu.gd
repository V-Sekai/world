extends Control

@export var ip: LineEdit = null
@export var port: SpinBox = null
@export var max_player: SpinBox = null
@export var dedicated_server: CheckBox = null

func _on_HostButton_pressed():
	GameManager.host_server(port.value, max_player.value, dedicated_server.is_pressed())

func _on_JoinButton_pressed():
	GameManager.join_server(ip.text, port.value)
