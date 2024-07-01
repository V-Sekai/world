extends "res://addons/gut/test.gd"

var wfc: RefCounted

const const_graph_grammar = preload("res://graph_grammar.gd")
var improv = preload("res://improv.gd").new()

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
		for graph in improv.possible_types.node_labels:
			possible_tiles.append(graph)
		state[i] = { "tile": null, "possible_tiles": possible_tiles }
	var todo_list: Array = [["meta_collapse_wave_function"]]
	var planner = Plan.new()
	planner.current_domain = wfc
	planner.verbose = 0
	gut.p(todo_list)
	gut.p(state)
	var graph_grammar = const_graph_grammar.plan_to_graph_grammar(todo_list, state)
	gut.p(graph_grammar)
	var result = planner.find_plan(state, todo_list)
	#var is_valid = wfc.is_valid_sequence(state)
	#assert_true(is_valid, "The sequence is valid.")
	gut.p(result)
	gut.p(state)
	graph_grammar = const_graph_grammar.plan_to_graph_grammar(result, state)
	gut.p(graph_grammar)
	assert_eq_deep(result, [["set_tile_state", 0, "root"], ["set_tile_state", 1, "Bob"], ["set_tile_state", 2, ": I have a"], ["set_tile_state", 3, "dog"], ["set_tile_state", 4, "who is"], ["set_tile_state", 5, "2 years old."], ["set_tile_state", 6, "end"]])
