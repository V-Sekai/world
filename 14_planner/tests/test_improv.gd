extends "res://addons/gut/test.gd"

func test_find_lowest_entropy_square():
	var state = {
		"has_possible_tiles": {
			0: ["root", "Bob", "Alice"],
			1: ["root", "Bob"]
		},
		"is_tile": {
			0: null,
			1: null
		}
	}
	assert_eq(Improv._find_lowest_entropy_square(state), 1)
	state["has_possible_tiles"][0].erase("Alice")
	assert_eq(Improv._find_lowest_entropy_square(state), 0)

func test_array_difference():
	var a1 = ["A", "B", "C"]
	var a2 = ["B"]
	assert_eq(Improv.array_difference(a1, a2), ["A", "C"])

func merge_dicts(dict1, dict2):
	for key in dict2:
		if key in dict1 and dict1[key] is Dictionary and dict2[key] is Dictionary:
			merge_dicts(dict1[key], dict2[key])
		else:
			dict1[key] = dict2[key]
	return dict1

func test_find_plan():
	var state = {}
	var improv: Improv = Improv.new()
	var planner = Plan.new()
	planner.current_domain = Improv.new()
	planner.verbose = 0
	var production_rules: Array[GraphGrammar.ProductionRule] = [
		GraphGrammar.ProductionRule.new("ex:rule1", "gg:Rule", "root", [{"node": "Bob", "edge": "next"}, {"node": "Alice", "edge": "next"}, {"node": "Carol", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule2", "gg:Rule", "Bob", [{"node": ": I have a", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule3", "gg:Rule", "Alice", [{"node": ": I have a", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule4", "gg:Rule", "Carol", [{"node": ": I have a", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule5", "gg:Rule", ": I have a", [{"node": "dog", "edge": "next"}, {"node": "cat", "edge": "next"}, {"node": "parrot", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule6", "gg:Rule", "dog", [{"node": "who is", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule7", "gg:Rule", "cat", [{"node": "who is", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule8", "gg:Rule", "parrot", [{"node": "who is", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule9", "gg:Rule", "who is", [{"node": "2 years old.", "edge": "next"}, {"node": "3 years old.", "edge": "next"}, {"node": "4 years old.", "edge": "next"}, {"node": "5 years old.", "edge": "next"}, {"node": "6 years old.", "edge": "next"}, {"node": "7 years old.", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule10", "gg:Rule", "2 years old.", [{"node": "end", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule11", "gg:Rule", "3 years old.", [{"node": "end", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule12", "gg:Rule", "4 years old.", [{"node": "end", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule13", "gg:Rule", "5 years old.", [{"node": "end", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule14", "gg:Rule", "6 years old.", [{"node": "end", "edge": "next"}]),
		GraphGrammar.ProductionRule.new("ex:rule15", "gg:Rule", "7 years old.", [{"node": "end", "edge": "next"}])
	]
	planner.current_domain.possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 
		["end"], 
		["next"], 
		["next"], 
		production_rules,
		"root"
	)

	for i in range(7):
		var possible_tiles = []
		for graph in planner.current_domain.possible_types.node_labels:
			possible_tiles.append(graph)
		state = merge_dicts(state, {"has_possible_tiles": {i: possible_tiles}})
		state = merge_dicts(state, {"is_tile": {i: null}})
	
	var todo_list: Array = [["meta_collapse_wave_function"]]
	assert_eq_deep(todo_list, [["meta_collapse_wave_function"]])
	gut.p("State: ")
	gut.p(state)
	assert_eq_deep(state, { "has_possible_tiles": { 0: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 1: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 2: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 3: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 4: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 5: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 6: ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"] }, "is_tile": { 0: null, 1: null, 2: null, 3: null, 4: null, 5: null, 6: null } })
	var result = planner.find_plan(state, todo_list)
	assert_eq_deep(result, [["print_side_effect", "root"], ["set_tile_state", 0, "root"], ["print_side_effect", "Carol"], ["set_tile_state", 1, "Carol"], ["print_side_effect", ": I have a"], ["set_tile_state", 2, ": I have a"], ["print_side_effect", "parrot"], ["set_tile_state", 3, "parrot"], ["print_side_effect", "who is"], ["set_tile_state", 4, "who is"], ["print_side_effect", "7 years old."], ["set_tile_state", 5, "7 years old."], ["print_side_effect", "end"], ["set_tile_state", 6, "end"]])
	assert_eq_deep(state,{ "has_possible_tiles": { 0: ["root"], 1: ["Carol"], 2: [": I have a"], 3: ["parrot"], 4: ["who is"], 5: ["7 years old."], 6: ["end"] }, "is_tile": { 0: "root", 1: "Carol", 2: ": I have a", 3: "parrot", 4: "who is", 5: "7 years old.", 6: "end" } })
