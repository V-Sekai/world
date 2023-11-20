extends Node


@onready var FadeIn = $Transition/FadeIn
@onready var FadeOut = $Transition/Fadeout


func _ready():
	FadeIn.play_backwards("Fade")


func _on_ChangeSceneTimer_timeout():
	FadeOut.play("Fade")


func _on_Fadeout_animation_finished(_anim_name):
	if get_tree().change_scene_to_file("res://DGILoadScreen/DGISplashScreen.tscn") != OK:
		print("Failed to Load DGISplashScreen.")


func _on_FadeIn_animation_finished(_anim_name):
	$ChangeSceneTimer.start()
