extends "res://addons/gut/test.gd"

var wfc: RefCounted

func before_each():
	# Create an instance of the class we're testing
	wfc = load("res://wfc.gd").new()

func after_each():
	pass

func test_calculate_entropy():
	var square = {"possible_tiles": ["A", "B", "C"]}
	assert_eq(wfc._calculate_entropy(square), 3)

func test_find_lowest_entropy_square():
	var state = {
		"1": {"possible_tiles": ["A", "B", "C"]},
		"2": {"possible_tiles": ["A", "B"]},
		"3": {"possible_tiles": ["A"]}
	}
	assert_eq(wfc._find_lowest_entropy_square(state), "2")

func test_array_difference():
	var a1 = ["A", "B", "C"]
	var a2 = ["B"]
	assert_eq(wfc.array_difference(a1, a2), ["A", "C"])
