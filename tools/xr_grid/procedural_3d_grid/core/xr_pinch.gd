# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# xr_pinch.gd
# SPDX-License-Identifier: MIT

extends Node3D

@export var hand_left: XRController3D = null
@export var hand_right: XRController3D = null

var prev_hand_left_transform: Transform3D
var prev_hand_right_transform: Transform3D
var prev_hand_left_grab: float = 0
var prev_hand_right_grab: float = 0

var _world_grab = WorldGrab.new()

var from_pivot: Vector3
var to_pivot: Vector3
var grab_pivot: Vector3
var delta_transform: Transform3D
var target_transform: Transform3D = transform

var damping: float = 6.0
const max_pinch_time: float = 0.1  # sensitivity?

enum Mode {
	NONE,
	GRAB,
	PINCH,
	ORBIT,
}
var state: Mode = Mode.NONE

var left_hand_just_grabbed := BoolTimer.new()
var right_hand_just_grabbed := BoolTimer.new()
var left_hand_just_ungrabbed := BoolTimer.new()
var right_hand_just_ungrabbed := BoolTimer.new()


func _process(delta_time: float) -> void:
	var hand_left_grab: float = hand_left.get_float("grip")
	var hand_right_grab: float = hand_right.get_float("grip")

	# Dampening
	delta_transform = delta_transform.interpolate_with(Transform3D(), damping * delta_time)

	update_hand_grab_status(hand_left_grab, prev_hand_left_grab, left_hand_just_grabbed, left_hand_just_ungrabbed)
	update_hand_grab_status(hand_right_grab, prev_hand_right_grab, right_hand_just_grabbed, right_hand_just_ungrabbed)

	var both_hands_just_ungrabbed: bool = left_hand_just_ungrabbed.value and right_hand_just_ungrabbed.value

	if both_hands_just_grabbed():
		state = Mode.PINCH
	if not (hand_left_grab or hand_right_grab):
		state = Mode.NONE
		delta_transform = Transform3D()  # Reset delta_transform when not grabbing

	match state:
		Mode.NONE:
			if hand_left_grab and not left_hand_just_grabbed.value:
				state = Mode.GRAB
			elif hand_right_grab and not right_hand_just_grabbed.value:
				state = Mode.GRAB

		Mode.GRAB:
			if hand_left_grab and hand_right_grab:
				state = Mode.ORBIT

			set_pivot_and_transform(hand_left_grab, prev_hand_left_transform, hand_left.transform)
			set_pivot_and_transform(hand_right_grab, prev_hand_right_transform, hand_right.transform)

		Mode.PINCH:
			if not (hand_left_grab and hand_right_grab) and both_hands_just_ungrabbed:
				state = Mode.GRAB

			set_pinch_pivot_and_transform(prev_hand_left_transform.origin, prev_hand_right_transform.origin, hand_left.transform.origin, hand_right.transform.origin)

		Mode.ORBIT:
			if not (hand_left_grab and hand_right_grab):
				state = Mode.GRAB

			set_orbit_pivot_and_transform(prev_hand_left_transform.origin, prev_hand_right_transform.origin, hand_left.transform.origin, hand_right.transform.origin)

	# Integrate motion
	target_transform = delta_transform * target_transform

	# Smoothing
	transform = _world_grab.split_blend(transform, target_transform, .3, .1, .1, transform * target_transform.affine_inverse() * to_pivot, to_pivot)

	# Pass data required for the next frame
	prev_hand_left_transform = hand_left.transform
	prev_hand_right_transform = hand_right.transform
	prev_hand_left_grab = hand_left_grab
	prev_hand_right_grab = hand_right_grab


func both_hands_just_grabbed() -> bool:
	return left_hand_just_grabbed.value and right_hand_just_grabbed.value


func update_hand_grab_status(hand_grab: float, prev_hand_grab: float, just_grabbed: BoolTimer, just_ungrabbed: BoolTimer) -> void:
	if hand_grab and not prev_hand_grab:
		just_grabbed.set_true(max_pinch_time)
	if not hand_grab and prev_hand_grab:
		just_ungrabbed.set_true(max_pinch_time)


func set_pivot_and_transform(hand_grab: float, prev_hand_transform: Transform3D, hand_transform: Transform3D) -> void:
	if hand_grab:
		from_pivot = prev_hand_transform.origin
		to_pivot = prev_hand_transform.origin
		delta_transform = _world_grab.get_grab_transform(prev_hand_transform, hand_transform)


func set_pinch_pivot_and_transform(prev_hand_left_origin: Vector3, prev_hand_right_origin: Vector3, hand_left_origin: Vector3, hand_right_origin: Vector3) -> void:
	from_pivot = (prev_hand_left_origin + prev_hand_right_origin) / 2.0
	to_pivot = (hand_left_origin + hand_right_origin) / 2.0
	delta_transform = _world_grab.get_pinch_transform(prev_hand_left_origin, prev_hand_right_origin, hand_left_origin, hand_right_origin)


func set_orbit_pivot_and_transform(prev_hand_left_origin: Vector3, prev_hand_right_origin: Vector3, hand_left_origin: Vector3, hand_right_origin: Vector3) -> void:
	from_pivot = prev_hand_left_origin
	to_pivot = prev_hand_right_origin
	delta_transform = _world_grab.get_orbit_transform(prev_hand_left_origin, prev_hand_right_origin, hand_left_origin, hand_right_origin)
