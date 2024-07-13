extends "res://addons/gut/test.gd"

var wfc: RefCounted

func before_each():
	wfc = load("res://magical_college.gd").new()

func test_calculate_entropy():
	var square = {"possible_tiles": ["A", "B", "C"]}
	assert_eq(wfc._calculate_entropy(square), 3)

func test_array_difference():
	var a1 = ["A", "B", "C"]
	var a2 = ["B"]
	assert_eq(wfc.array_difference(a1, a2), ["A", "C"])
