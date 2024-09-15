extends "res://addons/gut/test.gd"


func test_custom_avatar_find_plan():
	var drag_drop_outfit = GraphGrammar.ProductionRule.new("ex:drag_drop_outfit", "gg:Rule", "setup_outfit_prefab", [{"node": "Drag and drop the outfit prefab onto the avatar.", "edge": "description"}, {"node": "setup_animators", "edge": "next"}])
	var animator_setup = GraphGrammar.ProductionRule.new("ex:animator_setup", "gg:Rule", "setup_animators", [{"node": "Set up your animators as normal.", "edge": "description"}, {"node": "after_setup", "edge": "next"}])
	var post_setup = GraphGrammar.ProductionRule.new("ex:post_setup", "gg:Rule", "after_setup", [{"node": "Drag and drop the outfit prefab onto the avatar.", "edge": "description"}, {"node": "merge_bones", "edge": "next"}])
	var merge_bones = GraphGrammar.ProductionRule.new("ex:merge_bones", "gg:Rule", "merge_bones", [{"node": "The component will automatically merge the bone hierarchy with the original avatar's bones.", "edge": "description"}, {"node": "setup_bone_proxies", "edge": "next"}])
	var setup_bone_proxies = GraphGrammar.ProductionRule.new("ex:setup_bone_proxies", "gg:Rule", "setup_bone_proxies", [{"node": "Set up bone proxies for all collider objects.", "edge": "description"}, {"node": "setup_cloth_colliders", "edge": "next"}])
	var setup_cloth_colliders = GraphGrammar.ProductionRule.new("ex:setup_cloth_colliders", "gg:Rule", "setup_cloth_colliders", [{"node": "Ensure cloth colliders are working correctly.", "edge": "description"}, {"node": "setup_blendshape_sync", "edge": "next"}])
	var setup_blendshape_sync = GraphGrammar.ProductionRule.new("ex:setup_blendshape_sync", "gg:Rule", "setup_blendshape_sync", [{"node": "Set up blendshape sync components for Skirt and Tops.", "edge": "description"}])

	var setup_materials = GraphGrammar.ProductionRule.new("ex:setup_materials", "gg:Rule", "setup_materials", [{"node": "Apply materials to the avatar.", "edge": "description"}, {"node": "finalize_setup", "edge": "next"}])
	var finalize_setup = GraphGrammar.ProductionRule.new("ex:finalize_setup", "gg:Rule", "finalize_setup", [{"node": "Finalize the avatar setup.", "edge": "description"}, {"node": "setup_outfit_prefab", "edge": "next"}])

	var production_rules: Array[GraphGrammar.ProductionRule]
	production_rules.append(drag_drop_outfit)
	production_rules.append(animator_setup)
	production_rules.append(post_setup)
	production_rules.append(merge_bones)
	production_rules.append(setup_bone_proxies)
	production_rules.append(setup_cloth_colliders)
	production_rules.append(setup_blendshape_sync)
	production_rules.append(setup_materials)
	production_rules.append(finalize_setup)
   
	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["merge_bones", "setup_bone_proxies", "setup_cloth_colliders", "setup_blendshape_sync", "after_setup", "setup_animators", "setup_outfit_prefab", "setup_materials", "finalize_setup"], 
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
	var todo_list: Array = [["behave"]]
	planner.verbose = 0
	assert_eq_deep(todo_list,  [["behave"]])
	assert_eq_deep(state, {})
	var result = planner.find_plan(state, todo_list)
	assert_eq_deep(state, { "messages": ["Drag and drop the outfit prefab onto the avatar.", "setup_animators", "Set up your animators as normal.", "after_setup", "merge_bones", "The component will automatically merge the bone hierarchy with the original avatar\'s bones.", "setup_bone_proxies", "Set up bone proxies for all collider objects.", "setup_cloth_colliders", "Ensure cloth colliders are working correctly.", "setup_blendshape_sync", "Set up blendshape sync components for Skirt and Tops."]})
	assert_eq_deep(result,  [["print_side_effect", "Drag and drop the outfit prefab onto the avatar."], ["append_tile_state", "Drag and drop the outfit prefab onto the avatar."], ["print_side_effect", "setup_animators"], ["append_tile_state", "setup_animators"], ["print_side_effect", "Set up your animators as normal."], ["append_tile_state", "Set up your animators as normal."], ["print_side_effect", "after_setup"], ["append_tile_state", "after_setup"], ["print_side_effect", "merge_bones"], ["append_tile_state", "merge_bones"], ["print_side_effect", "The component will automatically merge the bone hierarchy with the original avatar\'s bones."], ["append_tile_state", "The component will automatically merge the bone hierarchy with the original avatar\'s bones."], ["print_side_effect", "setup_bone_proxies"], ["append_tile_state", "setup_bone_proxies"], ["print_side_effect", "Set up bone proxies for all collider objects."], ["append_tile_state", "Set up bone proxies for all collider objects."], ["print_side_effect", "setup_cloth_colliders"], ["append_tile_state", "setup_cloth_colliders"], ["print_side_effect", "Ensure cloth colliders are working correctly."], ["append_tile_state", "Ensure cloth colliders are working correctly."], ["print_side_effect", "setup_blendshape_sync"], ["append_tile_state", "setup_blendshape_sync"], ["print_side_effect", "Set up blendshape sync components for Skirt and Tops."], ["append_tile_state", "Set up blendshape sync components for Skirt and Tops."]]
	)
