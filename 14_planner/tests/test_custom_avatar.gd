extends "res://addons/gut/test.gd"

func merge_dicts(dict1, dict2):
	for key in dict2:
		if key in dict1 and dict1[key] is Dictionary and dict2[key] is Dictionary:
			merge_dicts(dict1[key], dict2[key])
		else:
			dict1[key] = dict2[key]
	return dict1

func test_custom_avatar_find_plan():
	var drag_drop_outfit = GraphGrammar.ProductionRule.new("ex:drag_drop_outfit", "gg:Rule", "setup_outfit_prefab", [{"node": "Drag and drop the outfit prefab onto the avatar.", "edge": "description"}, {"node": "setup_animators", "edge": "next"}])
	var animator_setup = GraphGrammar.ProductionRule.new("ex:animator_setup", "gg:Rule", "setup_animators", [{"node": "Set up your animators as normal.", "edge": "description"}, {"node": "after_setup", "edge": "next"}])
	var post_setup = GraphGrammar.ProductionRule.new("ex:post_setup", "gg:Rule", "after_setup", [{"node": "Drag and drop the outfit prefab onto the avatar.", "edge": "description"}, {"node": "merge_bones", "edge": "next"}])
	var merge_bones = GraphGrammar.ProductionRule.new("ex:merge_bones", "gg:Rule", "merge_bones", [{"node": "The component will automatically merge the bone hierarchy with the original avatar's bones.", "edge": "description"}, {"node": "setup_bone_proxies", "edge": "next"}])
	var setup_bone_proxies = GraphGrammar.ProductionRule.new("ex:setup_bone_proxies", "gg:Rule", "setup_bone_proxies", [{"node": "Set up bone proxies for all collider objects.", "edge": "description"}, {"node": "setup_cloth_colliders", "edge": "next"}])
	var setup_cloth_colliders = GraphGrammar.ProductionRule.new("ex:setup_cloth_colliders", "gg:Rule", "setup_cloth_colliders", [{"node": "Ensure cloth colliders are working correctly.", "edge": "description"}, {"node": "setup_blendshape_sync", "edge": "next"}])
	var setup_blendshape_sync = GraphGrammar.ProductionRule.new("ex:setup_blendshape_sync", "gg:Rule", "setup_blendshape_sync", [{"node": "Set up blendshape sync components for Skirt and Tops.", "edge": "description"}])

	var production_rules: Array[GraphGrammar.ProductionRule]
	production_rules.append(drag_drop_outfit)
	production_rules.append(animator_setup)
	production_rules.append(post_setup)
	production_rules.append(merge_bones)
	production_rules.append(setup_bone_proxies)
	production_rules.append(setup_cloth_colliders)
	production_rules.append(setup_blendshape_sync)
   
	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["merge_bones", "setup_bone_proxies", "setup_cloth_colliders", "setup_blendshape_sync", "after_setup", "setup_animators", "setup_outfit_prefab"], 
		["setup_blendshape_sync"], 
		["next", "description"], 
		["next", "description"], 
		production_rules,
		"setup_outfit_prefab"
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
	var todo_list: Array = [["meta_collapse_wave_function", planner.current_domain.GridDimensions.new()]]
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
	assert_eq_deep(result, [["print_side_effect", "setup_outfit_prefab"], ["set_tile_state", 0, "setup_outfit_prefab"], ["print_side_effect", "setup_animators"], ["set_tile_state", 1, "setup_animators"], ["print_side_effect", "after_setup"], ["set_tile_state", 2, "after_setup"], ["print_side_effect", "merge_bones"], ["set_tile_state", 3, "merge_bones"], ["print_side_effect", "setup_bone_proxies"], ["set_tile_state", 4, "setup_bone_proxies"], ["print_side_effect", "setup_cloth_colliders"], ["set_tile_state", 5, "setup_cloth_colliders"], ["print_side_effect", "setup_blendshape_sync"], ["set_tile_state", 6, "setup_blendshape_sync"]]
	)
