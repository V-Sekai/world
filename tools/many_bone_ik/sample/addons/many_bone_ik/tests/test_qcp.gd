# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# test_qcp.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var epsilon = 0.00001

const qcp_const = preload("res://addons/many_bone_ik/qcp.gd")


func setup():
	var qcp := qcp_const.new(epsilon)
	var original := PackedVector3Array([Vector3(1, 1, 1), Vector3(2, 2, 2), Vector3(3, 3, 3)])
	return [qcp, original]


func test_weighted_superpose_with_translation():
	var setup_data = setup()
	var qcp = setup_data[0]
	var moved = setup_data[1]

	var expected: Quaternion = Quaternion(0.3826834323650898, 0, 0, 0.9238795325112867).normalized()

	var target: PackedVector3Array = moved.duplicate()
	var translation_vector := Vector3(0, 0, 0)

	for i in range(target.size()):
		target[i] = expected.inverse() * (target[i] + translation_vector)

	var weight := [1.0, 1.0, 1.0]  # Equal weights
	var translate := false
	gut.p("Expected rotation: %s" % expected)
	gut.p("Initial moved: %s" % moved)
	gut.p("Expected target: %s" % target)
	assert_ne_deep(moved, target)
	var result: Quaternion = qcp.weighted_superpose(moved, target, weight, translate)
	gut.p("Result rotation: %s" % result)

	assert_almost_eq(result.x, expected.x, epsilon)
	assert_almost_eq(result.y, expected.y, epsilon)
	assert_almost_eq(result.z, expected.z, epsilon)
	assert_almost_eq(result.w, expected.w, epsilon)

	assert_eq(translate, false)
	var translation_result: Vector3 = qcp.get_translation()
	gut.p("Expected translation: %s" % translation_vector)
	gut.p("Result translation: %s" % translation_result)
	assert_almost_eq(translation_result.x, translation_vector.x, epsilon)
	assert_almost_eq(translation_result.y, translation_vector.y, epsilon)
	assert_almost_eq(translation_result.z, translation_vector.z, epsilon)


func test_get_rotation_xform():
	# Arrange
	var moved = [Vector3(0, 1, 0)]
	var expected_rotation = Quaternion(0.3826834323650898, 0, 0, 0.9238795325112867)
	var expected_vector = Vector3(1, 0, 0)
	var target = expected_rotation * expected_vector 
	gut.p("Expected Rotation: %s" % str(expected_rotation))
	gut.p("Target: %s" % target[0])

	# Act
	var result = expected_rotation.inverse() * target

	# Log the result
	gut.p("Result of calculate_rotation: %s" % result)

	# Assert
	assert_eq(result, expected_vector)
	
	
