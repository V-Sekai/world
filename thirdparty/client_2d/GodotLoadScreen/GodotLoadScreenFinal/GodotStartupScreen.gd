extends ColorRect

@onready var godotSprite = $Control/GodotAnimatedSprite
@onready var godotTXT = $Control/Godot
@onready var lightFlikceringSound = $LightFlickerSound
@onready var animation = $SceneTransition/AnimationPlayer
var tween: Tween = null


func _ready():
	tween = create_tween()
	tween.play()
	lightFlikceringSound.play()
	godotTXT.set("modulate", tween.interpolate_value(Color(1, 1, 1, 0), Color(1, 1, 1, 0).lerp(Color(1, 1, 1, 1), 1), 0, 1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT))


func _process(delta):
	godotTXT.set("modulate", tween.interpolate_value(godotTXT.modulate, Color(1, 1, 1, 0).lerp(Color(1, 1, 1, 1), 1), delta, 1, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT))


func _on_AnimationPlayTimer_timeout():
	godotSprite.play()


func _on_GodotAnimatedSprite_animation_finished():
	$ChangeSceneTimer.start()


func _on_ChangeSceneTimer_timeout():
	animation.play("Fade")


func _on_AnimationPlayer_animation_finished(_anim_name):
	if get_tree().change_scene_to_file("res://WPMLoadScreen/WPMSplashScreen.tscn") != OK:
		print("Failed to Load WPMSplashScreen.")
