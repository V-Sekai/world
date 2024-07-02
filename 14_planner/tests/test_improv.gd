extends "res://addons/gut/test.gd"

func test_calculate_entropy():
	var square = {"possible_tiles": ["A", "B", "C"]}
	assert_eq(Improv._calculate_entropy(square), 3)

func test_array_difference():
	var a1 = ["A", "B", "C"]
	var a2 = ["B"]
	assert_eq(Improv.array_difference(a1, a2), ["A", "C"])

func test_find_plan():
	var state = {}
	var improv: Improv = Improv.new()
	var planner = Plan.new()
	planner.current_domain = Improv.new()
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
		state[i] = { "tile": null, "possible_tiles": possible_tiles }
	var todo_list: Array = [["meta_collapse_wave_function"]]
	planner.verbose = 0
	gut.p("Todo list: ")
	gut.p(todo_list)
	gut.p("State: ")
	gut.p(state)
	gut.p("Graph Grammar: ")
	var result = planner.find_plan(state, todo_list)
	gut.p("Result: ")
	gut.p(result)
	gut.p("State: ")
	gut.p(state)
	assert_eq_deep(result, [["set_tile_state", 0, "root"], ["set_tile_state", 1, "Carol"], ["set_tile_state", 2, ": I have a"], ["set_tile_state", 3, "parrot"], ["set_tile_state", 4, "who is"], ["set_tile_state", 5, "7 years old."], ["set_tile_state", 6, "end"]])
