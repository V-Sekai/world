@tool
@icon("res://addons/AnimationProviders/editor/AnimationProvider.svg")
class_name AnimationProvider
extends Node


## Animation Provider Base Script
##
## Animation Providers feed live-animation data to an [AnimationPlayer]. To
## use Animation Providers, add the appropriate provider for your live-animation
## or mocap hardware as a child of an [AnimationPlayer].


# Animation library instance
var _library : AnimationLibrary


# Handle node ready
func _ready() -> void:
	# Get the animation mixer
	var mixer := get_parent() as AnimationMixer
	if not mixer:
		# No mixer - skip processing
		set_physics_process(false)
		return

	# Get (or create) the animation library
	if mixer.has_animation_library(name):
		_library = mixer.get_animation_library(name)
	else:
		_library = AnimationLibrary.new()
		_library.resource_name = name
		_library.resource_local_to_scene = true
		mixer.add_animation_library(name, _library)

	# Initialize the animation
	_initialize_animations()

	# Populate the animations
	_populate_animations()


# Check for configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Check correct parent node
	var mixer := get_parent() as AnimationMixer
	if not mixer:
		warnings.append(
			"Parent node is not AnimationMixer (AnimationPlayer or AnimationTree)")

	return warnings


# Called during the physics processing step of the main loop
func _physics_process(_delta : float) -> void:
	_update_animations()


## Get the animation library
func get_library() -> AnimationLibrary:
	return _library


# Initialize the animations (implemented in providers)
func _initialize_animations() -> void:
	push_error("Only implementations of AnimationProvider should be used")
	breakpoint


# Populate the animations (implemented in providers)
func _populate_animations() -> void:
	push_error("Only implementations of AnimationProvider should be used")
	breakpoint


# Update the animations (implemented in providers)
func _update_animations() -> void:
	push_error("Only implementations of AnimationProvider should be used")
	breakpoint
