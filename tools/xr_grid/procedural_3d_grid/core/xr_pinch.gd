# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# xr_pinch.gd
# SPDX-License-Identifier: MIT

extends Node3D

# The nodes referencing the left and right hand controllers.
@export var hand_left: XRController3D = null
@export var hand_right: XRController3D = null

# Previous frame's transform for each hand.
var prev_hand_left_transform: Transform3D
var prev_hand_right_transform: Transform3D

# Previous frame's grab strength (0.0 to 1.0) for each hand.
var prev_hand_left_grab: float = 0
var prev_hand_right_grab: float = 0

# Instance of a WorldGrab object which handles calculation of transformations.
var _world_grab = WorldGrab.new()

# Pivot points and transformation variables.
var from_pivot: Vector3
var to_pivot: Vector3
var grab_pivot: Vector3
var delta_transform: Transform3D
var target_transform: Transform3D = transform

# Damping factor for smoothing the motion.
var damping: float = 6.0

# Maximum time for considering an input as a pinch action.
const max_pinch_time: float = 0.1

# Enum to represent the different modes of operation.
enum Mode {
	NONE,
	GRAB,
	PINCH,
	ORBIT,
}
# State variable holding the current mode.
var state: Mode = Mode.NONE

# Timers for detecting just grabbed and just ungrabbed actions for both hands.
var left_hand_just_grabbed := BoolTimer.new()
var right_hand_just_grabbed := BoolTimer.new()
var left_hand_just_ungrabbed := BoolTimer.new()
var right_hand_just_ungrabbed := BoolTimer.new()


func _process(delta_time: float) -> void:
	var hand_left_grab: float = hand_left.get_float("grip")
	var hand_right_grab: float = hand_right.get_float("grip")

	# Apply damping to the delta_transform to reduce its magnitude over time smoothly.
	delta_transform = delta_transform.interpolate_with(Transform3D(), damping * delta_time)

	# Update the status of each hand's grabbing state.
	update_hand_grab_status(hand_left_grab, prev_hand_left_grab, left_hand_just_grabbed, left_hand_just_ungrabbed)
	update_hand_grab_status(hand_right_grab, prev_hand_right_grab, right_hand_just_grabbed, right_hand_just_ungrabbed)

	# Check if both hands have just released their grip.
	var both_hands_just_ungrabbed: bool = left_hand_just_ungrabbed.value and right_hand_just_ungrabbed.value

	if both_hands_just_grabbed():
		state = Mode.PINCH
	if not (hand_left_grab or hand_right_grab):
		state = Mode.NONE
		delta_transform = Transform3D()  # Reset delta_transform when not grabbing

	match state:
		Mode.NONE:
			# Transition to GRAB state if one hand starts grabbing.
			if hand_left_grab and not left_hand_just_grabbed.value:
				state = Mode.GRAB
			elif hand_right_grab and not right_hand_just_grabbed.value:
				state = Mode.GRAB

		Mode.GRAB:
			# Transition to ORBIT state if both hands are grabbing.
			if hand_left_grab and hand_right_grab:
				state = Mode.ORBIT

			set_pivot_and_transform(hand_left_grab, prev_hand_left_transform, hand_left.transform)
			set_pivot_and_transform(hand_right_grab, prev_hand_right_transform, hand_right.transform)

		Mode.PINCH:
			# Return to GRAB state if the pinch is released.
			if not (hand_left_grab and hand_right_grab) and both_hands_just_ungrabbed:
				state = Mode.GRAB

			set_pinch_pivot_and_transform(prev_hand_left_transform.origin, prev_hand_right_transform.origin, hand_left.transform.origin, hand_right.transform.origin)

		Mode.ORBIT:
			# Return to GRAB state if one of the hands stops grabbing.
			if not (hand_left_grab and hand_right_grab):
				state = Mode.GRAB

			set_orbit_pivot_and_transform(prev_hand_left_transform.origin, prev_hand_right_transform.origin, hand_left.transform.origin, hand_right.transform.origin)

	# Apply the calculated transformation to determine the new target position.
	target_transform = delta_transform * target_transform

	# Perform smoothing between the current and target transforms.
	transform = _world_grab.split_blend(transform, target_transform, .3, .1, .1, transform * target_transform.affine_inverse() * to_pivot, to_pivot)

	# Update previous frame data for the next iteration.
	prev_hand_left_transform = hand_left.transform
	prev_hand_right_transform = hand_right.transform
	prev_hand_left_grab = hand_left_grab
	prev_hand_right_grab = hand_right_grab


func both_hands_just_grabbed() -> bool:
	# Determine if both hands have just initiated a grabbing action.
	return left_hand_just_grabbed.value and right_hand_just_grabbed.value


func update_hand_grab_status(hand_grab: float, prev_hand_grab: float, just_grabbed: BoolTimer, just_ungrabbed: BoolTimer) -> void:
	# Update the grab timers based on the change in grab value.
	if hand_grab and not prev_hand_grab:
		just_grabbed.set_true(max_pinch_time)
	if not hand_grab and prev_hand_grab:
		just_ungrabbed.set_true(max_pinch_time)


func set_pivot_and_transform(hand_grab: float, prev_hand_transform: Transform3D, hand_transform: Transform3D) -> void:
	# Calculate pivot points and delta transformation for a single hand grabbing scenario.
	if hand_grab:
		from_pivot = prev_hand_transform.origin
		to_pivot = hand_transform.origin
		delta_transform = _world_grab.get_grab_transform(prev_hand_transform, hand_transform)


func set_pinch_pivot_and_transform(prev_hand_left_origin: Vector3, prev_hand_right_origin: Vector3, hand_left_origin: Vector3, hand_right_origin: Vector3) -> void:
	# Calculate pivot points and delta transformation for a pinch scenario.
	from_pivot = (prev_hand_left_origin + prev_hand_right_origin) / 2.0
	to_pivot = (hand_left_origin + hand_right_origin) / 2.0
	delta_transform = _world_grab.get_pinch_transform(prev_hand_left_origin, prev_hand_right_origin, hand_left_origin, hand_right_origin)


func set_orbit_pivot_and_transform(prev_hand_left_origin: Vector3, prev_hand_right_origin: Vector3, hand_left_origin: Vector3, hand_right_origin: Vector3) -> void:
	# Calculate pivot points and delta transformation for an orbit scenario.
	from_pivot = hand_left_origin
	to_pivot = hand_right_origin
	delta_transform = _world_grab.get_orbit_transform(prev_hand_left_origin, prev_hand_right_origin, hand_left_origin, hand_right_origin)
