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
	var todo_list: Array = [["meta_collapse_wave_function"]]
	var planner = Plan.new()
	planner.current_domain = wfc
	planner.verbose = 1
	gut.p(todo_list)
	gut.p(state)
	var graph_grammar = plan_to_graph_grammar(todo_list, state)
	gut.p(graph_grammar)
	var result = planner.find_plan(state, todo_list)
	#var is_valid = wfc.is_valid_sequence(state)
	#assert_true(is_valid, "The sequence is valid.")
	gut.p(result)
	gut.p(state)
	graph_grammar = plan_to_graph_grammar(result, state)
	gut.p(graph_grammar)
	assert_eq_deep(result, [["set_tile_state", 0, "root"], ["set_tile_state", 1, "Bob"], ["set_tile_state", 2, ": I have a"], ["set_tile_state", 3, "dog"], ["set_tile_state", 4, "who is"], ["set_tile_state", 5, "2 years old."], ["set_tile_state", 6, "end"]])

func plan_to_graph_grammar(todo_list: Array, state: Dictionary) -> Dictionary:
	var graph_grammar = {
		"@context": {
			"gg": "http://v-sekai.com/graphgrammar#",
			"ex": "http://v-sekai.com/ex#"
		},
		"@id": "ex:myGraphGrammar",
		"@type": "gg:GraphGrammar",
		"gg:nodeLabels": [],
		"gg:terminalNodeLabels": [],
		"gg:edgeLabels": ["next"],
		"gg:finalEdgeLabels": ["next"],
		"gg:productionRules": [],
		"gg:initialNonterminalSymbol": todo_list[0][0]
	}

	for i in range(todo_list.size()):
		var node = todo_list[i][0]
		var possible_tiles = state[i]["possible_tiles"]

		# Add the node label to the list of all possible node labels
		if !graph_grammar["gg:nodeLabels"].has(node):
			graph_grammar["gg:nodeLabels"].append(node)

		# If this is the last node in the todo list, add it to the list of terminal node labels
		if i == todo_list.size() - 1:
			graph_grammar["gg:terminalNodeLabels"].append(node)

		# For each possible tile, create a production rule from the current node to that tile
		for tile in possible_tiles:
			var rule = {
				"@id": "ex:rule" + str(i),
				"@type": "gg:Rule",
				"gg:leftHandSide": node,
				"gg:rightHandSide": [{"node": tile, "edge": "next"}]
			}
			graph_grammar["gg:productionRules"].append(rule)

	return graph_grammar
