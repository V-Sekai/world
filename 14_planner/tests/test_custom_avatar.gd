extends "res://addons/gut/test.gd"

func test_custom_avatar_find_plan():
	var drag_drop_outfit = GraphGrammar.ProductionRule.new("DragDropOutfit", "gg:Rule", "setup_outfit_prefab", [{"node": "Drag and drop the outfit prefab onto the avatar.", "edge": "next"}])
	var animator_setup = GraphGrammar.ProductionRule.new("AnimatorSetup", "gg:Rule", "setup_animators", [{"node": "Set up your animators as normal.", "edge": "next"}])
	var post_setup = GraphGrammar.ProductionRule.new("PostSetup", "gg:Rule", "Drag and drop the outfit prefab onto the avatar.", [{"node": "after_setup", "edge": "next"}])
	var merge_bones = GraphGrammar.ProductionRule.new("MergeBones", "gg:Rule", "after_setup", [{"node": "The component will automatically merge the bone hierarchy with the original avatar's bones.", "edge": "next"}])
	var production_rules: Array[GraphGrammar.ProductionRule]
	production_rules.append(drag_drop_outfit)
	production_rules.append(animator_setup)
	production_rules.append(post_setup)
	production_rules.append(merge_bones)

	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["setup_outfit_prefab", "setup_animators", "Drag and drop the outfit prefab onto the avatar.", "after_setup", "The component will automatically merge the bone hierarchy with the original avatar's bones.", "end"], 
		["end"], 
		["next"], 
		["next"], 
		production_rules,
		"setup_outfit_prefab"
	)
	assert_true(!production_rules.is_empty())	
	var state = {}
	var planner = Plan.new()
	planner.current_domain = Improv.new()
	planner.current_domain.possible_types = possible_types
	for i in range(6):
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
	assert_eq_deep(result, [["set_tile_state", 0, "setup_outfit_prefab"], ["set_tile_state", 1, "Drag and drop the outfit prefab onto the avatar."], ["set_tile_state", 2, "after_setup"], ["set_tile_state", 3, "The component will automatically merge the bone hierarchy with the original avatar\'s bones."], ["set_tile_state", 4, "setup_outfit_prefab"], ["set_tile_state", 5, "Drag and drop the outfit prefab onto the avatar."]])
