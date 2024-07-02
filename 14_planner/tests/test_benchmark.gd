extends "res://addons/gut/test.gd"

func merge_dicts(dict1, dict2):
	for key in dict2:
		if key in dict1 and dict1[key] is Dictionary and dict2[key] is Dictionary:
			merge_dicts(dict1[key], dict2[key])
		else:
			dict1[key] = dict2[key]
	return dict1

func test_planner_benchmark():
	var production_rules: Array[GraphGrammar.ProductionRule]

	for i in range(999):
		var rule = GraphGrammar.ProductionRule.new("ex:rule_" + str(i), "gg:Rule", "setup_rule_" + str(i), [{"node": "This is rule number " + str(i), "edge": "description"}, {"node": "setup_rule_" + str(i+1), "edge": "next"}])
		production_rules.append(rule)

	var node_labels = ["setup_rule_999"]
	for i in range(999):
		node_labels.append("setup_rule_" + str(i))

	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		node_labels, 
		["setup_rule_999"], 
		["next", "description"], 
		["next", "description"], 
		production_rules,
		"setup_rule_0"
	)
	assert_true(!production_rules.is_empty())	
	var state = {}
	var planner = Plan.new()
	planner.current_domain = Improv.new()
	planner.current_domain.possible_types = possible_types
	var callable_array: Array[Callable]
	for element: String in possible_types.node_labels:
		planner.current_domain.add_task_methods(element, [planner.current_domain.apply_graph_grammar_node])
	for i in range(planner.current_domain.possible_types.node_labels.size()):
		var possible_tiles = []
		for graph in planner.current_domain.possible_types.node_labels:
			possible_tiles.append(graph)
		state = merge_dicts(state, {"has_possible_tiles": {i: possible_tiles}})
		state = merge_dicts(state, {"is_tile": {i: null}})
	var todo_list: Array = [["meta_collapse_wave_function"]]
	planner.verbose = 0
	var start_time = Time.get_ticks_msec()
	var result = planner.find_plan(state, todo_list)
	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	gut.p("Elapsed time: " + str(elapsed_time) + " ms")
	assert_eq(result.size(), 2000)
