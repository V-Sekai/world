extends Control

func _on_BackButton_pressed():
	if get_tree().change_scene("res://Menus/MainMenu.tscn") != OK:
		print("Failed to Load MainMenu.")
