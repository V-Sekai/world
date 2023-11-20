extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var version = ProjectSettings.get_setting("application/config/version")


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect/BuildNumber.text = "Build: " + str(version)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DiscordButton_pressed():
	OS.shell_open(Global.discord_url)


func _on_VerifyRegisterAccountButton_pressed():
	if get_tree().change_scene_to(preload("res://Menus/VerifyRegisterMenu.tscn")) != OK:
		print("Failed to Load MainMenu.")


func _on_RegisterButton_pressed():
	if get_tree().change_scene_to(preload("res://Menus/RegisterMenu.tscn")) != OK:
		print("Failed to Load MainMenu.")


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_LoginButton_pressed():
	$ColorRect/Login/LoginButton.disabled = true
	TcpClient.connect_and_send_username($ColorRect/Login/Username.text)
