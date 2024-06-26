extends "res://addons/gut/test.gd"

var wfc: RefCounted

func before_each():
	wfc = load("res://improv.gd").new()

func test_calculate_entropy():
	var square = {"possible_tiles": ["A", "B", "C"]}
	assert_eq(wfc._calculate_entropy(square), 3)

func test_array_difference():
	var a1 = ["A", "B", "C"]
	var a2 = ["B"]
	assert_eq(wfc.array_difference(a1, a2), ["A", "C"])

func test_find_plan():
	var state = {}
	for i in range(7):
		var possible_tiles = []
		for graph in wfc.possible_types["gg:nodeLabels"]:
			possible_tiles.append(graph)
		state[i] = { "tile": null, "possible_tiles": possible_tiles }
	var wfc_array: Array = []
	wfc_array.append(["meta_collapse_wave_function"])
	var planner = Plan.new()
	planner.current_domain = wfc
	planner.verbose = 1
	var result = planner.find_plan(state, wfc_array)
	#var is_valid = wfc.is_valid_sequence(state)
	#assert_true(is_valid, "The sequence is valid.")
	gut.p(result)
	assert_eq_deep(result, [["set_tile_state", 0, "Bob"], ["set_tile_state", 1, ": I have a"], ["set_tile_state", 2, "parrot"], ["set_tile_state", 3, "who is"], ["set_tile_state", 4, "7 years old."]])
