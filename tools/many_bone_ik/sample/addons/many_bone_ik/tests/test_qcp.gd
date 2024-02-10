# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
# test_qcp.gd
# SPDX-License-Identifier: MIT

extends "res://addons/gut/test.gd"

var epsilon = 0.000001

const qcp_const = preload("res://addons/many_bone_ik/qcp.gd")


func setup():
	var qcp := qcp_const.new(epsilon)
	var original := PackedVector3Array([Vector3(1, 1, 1)])
	return [qcp, original]

