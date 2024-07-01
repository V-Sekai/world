extends "res://addons/gut/test.gd"

var wfc: RefCounted
const const_graph_grammar = preload("res://graph_grammar.gd")

func before_each():
	wfc = load("res://wfc.gd").new()

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

func test_find_plan():
	var state = {}
	for i in range(wfc.tile_width):
		for j in range(wfc.tile_width):
			state[i * wfc.tile_width + j] = {
				"tile": null,
				"possible_tiles": wfc.possible_types.keys()
			}
	var wfc_array: Array
	wfc_array.append(["meta_collapse_wave_function"])
	var planner = Plan.new()
	planner.current_domain = wfc
	var result = planner.find_plan(state, wfc_array)
	gut.p(result)
	var graph_grammar: const_graph_grammar.GraphGrammar = const_graph_grammar.plan_to_graph_grammar(result, state)
	gut.p("Graph Grammar: ")
	gut.p(JSON.from_native(graph_grammar, true, true))
	planner.verbose = 0
	if wfc.is_valid_sequence(state):
		assert_true(true, "The sequence is valid.")
	else:
		assert_true(false, "The sequence is not valid.")
