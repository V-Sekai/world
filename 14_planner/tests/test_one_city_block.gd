extends "res://addons/gut/test.gd"

func merge_dicts(dict1, dict2):
	for key in dict2:
		if key in dict1 and dict1[key] is Dictionary and dict2[key] is Dictionary:
			merge_dicts(dict1[key], dict2[key])
		else:
			dict1[key] = dict2[key]
	return dict1
	
func z_order_index(x, y, n):
	var answer = 0
	for i in range(n, -1, -1):
		var bx = (x & (1 << i)) >> i
		var by = (y & (1 << i)) >> i
		answer += (bx << (2 * i + 1)) + (by << (2 * i))
	return answer

func print_state_as_utf8_map(state, pattern_size):
	var utf8_map = ""
	for i in range(pattern_size):
		for j in range(pattern_size):
			if state["is_tile"][i*pattern_size + j] == "sea":
				utf8_map += "🌊"
			elif state["is_tile"][i*pattern_size + j] == "coast":
				utf8_map += "🏖️"
			else:
				utf8_map += "🌳"
		utf8_map += "\n"
	print(utf8_map)

func test_custom_city_find_plan():
	var sea = GraphGrammar.ProductionRule.new("ex:sea", "gg:Rule", "sea", [{"node": "A vast body of water.", "edge": "description"}, {"node": "coast", "edge": "next"}])
	var coast = GraphGrammar.ProductionRule.new("ex:coast", "gg:Rule", "coast", [{"node": "The boundary between land and sea.", "edge": "description"}, {"node": "sea", "edge": "next"}, {"node": "land", "edge": "next"}])
	var land = GraphGrammar.ProductionRule.new("ex:land", "gg:Rule", "land", [{"node": "An expanse of solid ground.", "edge": "description"}, {"node": "coast", "edge": "next"}])
	var production_rules: Array[GraphGrammar.ProductionRule] = []

	var pattern: Array = [
		["l", "c", "l", "s", "c", "l", "s", "c", "l"],
		["s", "c", "s", "l", "c", "s", "l", "c", "s"],
		["l", "c", "l", "s", "c", "l", "s", "c", "l"],
		["s", "c", "s", "l", "c", "s", "l", "c", "s"],
		["l", "c", "l", "s", "c", "l", "s", "c", "l"],
		["s", "c", "s", "l", "c", "s", "l", "c", "s"],
		["l", "c", "l", "s", "c", "l", "s", "c", "l"],
		["s", "c", "s", "l", "c", "s", "l", "c", "s"],
		["l", "c", "l", "s", "c", "l", "s", "c", "l"]
	]
	var state = {}
	var planner = Plan.new()
	planner.current_domain = Improv.new()
	var grid_dimensions = planner.current_domain.GridDimensions.new(4, 4, 1)
	var pattern_size = grid_dimensions.width

	for x in range(pattern_size):
		for y in range(pattern_size):
			var wrapped_x = x % pattern_size
			var wrapped_y = y % pattern_size

			if pattern[wrapped_x][wrapped_y] == "s":
				var new_sea = GraphGrammar.ProductionRule.new("ex:sea" + str(wrapped_x) + str(wrapped_y), "gg:Rule", "sea", [{"node": "A vast body of water.", "edge": "description"}, {"node": "coast", "edge": "next"}])
				production_rules.append(new_sea)
			elif pattern[wrapped_x][wrapped_y] == "c":
				var new_coast = GraphGrammar.ProductionRule.new("ex:coast" + str(wrapped_x) + str(wrapped_y), "gg:Rule", "coast", [{"node": "The boundary between land and sea.", "edge": "description"}, {"node": "sea", "edge": "next"}, {"node": "land", "edge": "next"}])
				production_rules.append(new_coast)
			else:
				var new_land = GraphGrammar.ProductionRule.new("ex:land" + str(wrapped_x) + str(wrapped_y), "gg:Rule", "land", [{"node": "An expanse of solid ground.", "edge": "description"}, {"node": "coast", "edge": "next"}])
				production_rules.append(new_land)

	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["sea", "coast", "land"],
		["land"],
		["next", "description"], 
		["next", "description"], 
		production_rules,
		"land"
	)

	assert_true(!production_rules.is_empty())    
	planner.current_domain.rng_seed = hash("City bLock")
	planner.current_domain.possible_types = possible_types
	for element: String in possible_types.node_labels:
		planner.current_domain.add_task_methods(element, [planner.current_domain.apply_graph_grammar_node])
	for i in range(production_rules.size()):
		var possible_tiles = []
		for graph in planner.current_domain.possible_types.node_labels:
			possible_tiles.append(graph)
		state = merge_dicts(state, {"has_possible_tiles": {i: possible_tiles}})
		state = merge_dicts(state, {"is_tile": {i: null}})
	var todo_list: Array = [["meta_collapse_wave_function", grid_dimensions]]
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
	print_state_as_utf8_map(state, pattern_size)
	assert_eq_deep(result,  [["print_side_effect", "land"], ["set_tile_state", 0, "land"], ["print_side_effect", "coast"], ["set_tile_state", 1, "coast"], ["print_side_effect", "sea"], ["set_tile_state", 2, "sea"], ["print_side_effect", "coast"], ["set_tile_state", 3, "coast"], ["print_side_effect", "sea"], ["set_tile_state", 4, "sea"], ["print_side_effect", "coast"], ["set_tile_state", 5, "coast"], ["print_side_effect", "sea"], ["set_tile_state", 6, "sea"], ["print_side_effect", "coast"], ["set_tile_state", 7, "coast"], ["print_side_effect", "sea"], ["set_tile_state", 8, "sea"]]
	)
