extends "res://addons/gut/test.gd"


func test_construction_plan():
	var start = GraphGrammar.ProductionRule.new("ex:start", "gg:Rule", "start", [{"node": "Excavate and pour footers", "edge": "next"}])
	var excavate_pour_footers = GraphGrammar.ProductionRule.new("ex:excavate_pour_footers", "gg:Rule", "Excavate and pour footers", [{"node": "Pour concrete foundation", "edge": "next"}])
	var pour_concrete_foundation = GraphGrammar.ProductionRule.new("ex:pour_concrete_foundation", "gg:Rule", "Pour concrete foundation", [{"node": "Erect wooden frame including rough roof", "edge": "next"}])
	var erect_wooden_frame = GraphGrammar.ProductionRule.new("ex:erect_wooden_frame", "gg:Rule", "Erect wooden frame including rough roof", [{"node": "Lay brickwork", "edge": "next"}, {"node": "Install basement drains and plumbing", "edge": "next"}, {"node": "Install rough wiring", "edge": "next"}])
	var lay_brickwork = GraphGrammar.ProductionRule.new("ex:lay_brickwork", "gg:Rule", "Lay brickwork", [{"node": "Finish roofing and flashing", "edge": "next"}])
	var install_basement_drains = GraphGrammar.ProductionRule.new("ex:install_basement_drains", "gg:Rule", "Install basement drains and plumbing", [{"node": "Pour basement floor", "edge": "next"}, {"node": "Install rough plumbing", "edge": "next"}])
	var pour_basement_floor = GraphGrammar.ProductionRule.new("ex:pour_basement_floor", "gg:Rule", "Pour basement floor", [{"node": "Install heating and ventilating", "edge": "next"}])
	var install_rough_plumbing = GraphGrammar.ProductionRule.new("ex:install_rough_plumbing", "gg:Rule", "Install rough plumbing", [{"node": "Fasten plaster board and plaster (including drying)", "edge": "next"}])
	var install_rough_wiring = GraphGrammar.ProductionRule.new("ex:install_rough_wiring", "gg:Rule", "Install rough wiring", [{"node": "Fasten plaster board and plaster (including drying)", "edge": "next"}])
	var install_heating_ventilating = GraphGrammar.ProductionRule.new("ex:install_heating_ventilating", "gg:Rule", "Install heating and ventilating", [{"node": "Fasten plaster board and plaster (including drying)", "edge": "next"}])
	var fasten_plaster_board = GraphGrammar.ProductionRule.new("ex:fasten_plaster_board", "gg:Rule", "Fasten plaster board and plaster (including drying)", [{"node": "Lay finish flooring", "edge": "next"}])
	var lay_finish_flooring = GraphGrammar.ProductionRule.new("ex:lay_finish_flooring", "gg:Rule", "Lay finish flooring", [{"node": "Install kitchen fixtures", "edge": "next"}, {"node": "Install finish plumbing", "edge": "next"}, {"node": "Finish carpentry", "edge": "next"}])
	var install_kitchen_fixtures = GraphGrammar.ProductionRule.new("ex:install_kitchen_fixtures", "gg:Rule", "Install kitchen fixtures", [{"node": "Paint", "edge": "next"}])
	var install_finish_plumbing = GraphGrammar.ProductionRule.new("ex:install_finish_plumbing", "gg:Rule", "Install finish plumbing", [{"node": "Paint", "edge": "next"}])
	var finish_carpentry = GraphGrammar.ProductionRule.new("ex:finish_carpentry", "gg:Rule", "Finish carpentry", [{"node": "Sand and varnish flooring", "edge": "next"}])
	var paint = GraphGrammar.ProductionRule.new("ex:paint", "gg:Rule", "Paint", [{"node": "Finish electrical work", "edge": "next"}])
	var finish_electrical_work = GraphGrammar.ProductionRule.new("ex:finish_electrical_work", "gg:Rule", "Finish electrical work", [{"node": "Finish", "edge": "next"}])
	var finish = GraphGrammar.ProductionRule.new("ex:finish", "gg:Rule", "Finish", [])
	var finish_roofing_flashing = GraphGrammar.ProductionRule.new("ex:finish_roofing_flashing", "gg:Rule", "Finish roofing and flashing", [{"node": "Fasten gutters and downspouts", "edge": "next"}])
	var fasten_gutters_downspouts = GraphGrammar.ProductionRule.new("ex:fasten_gutters_downspouts", "gg:Rule", "Fasten gutters and downspouts", [{"node": "Finish grading", "edge": "next"}])
	var lay_storm_drains = GraphGrammar.ProductionRule.new("ex:lay_storm_drains", "gg:Rule", "Lay storm drains for rain water", [{"node": "Finish grading", "edge": "next"}])
	var finish_grading = GraphGrammar.ProductionRule.new("ex:finish_grading", "gg:Rule", "Finish grading", [{"node": "Pour walks and complete landscaping", "edge": "next"}])
	var pour_walks_landscaping = GraphGrammar.ProductionRule.new("ex:pour_walks_landscaping", "gg:Rule", "Pour walks and complete landscaping", [{"node": "Finish", "edge": "next"}])
	var sand_varnish_flooring = GraphGrammar.ProductionRule.new("ex:sand_varnish_flooring", "gg:Rule", "Sand and varnish flooring", [{"node": "Finish", "edge": "next"}])

	var production_rules: Array[GraphGrammar.ProductionRule] = []
	production_rules.append(start)
	production_rules.append(excavate_pour_footers)
	production_rules.append(pour_concrete_foundation)
	production_rules.append(erect_wooden_frame)
	production_rules.append(lay_brickwork)
	production_rules.append(install_basement_drains)
	production_rules.append(pour_basement_floor)
	production_rules.append(install_rough_plumbing)
	production_rules.append(install_rough_wiring)
	production_rules.append(install_heating_ventilating)
	production_rules.append(fasten_plaster_board)
	production_rules.append(lay_finish_flooring)
	production_rules.append(install_kitchen_fixtures)
	production_rules.append(install_finish_plumbing)
	production_rules.append(finish_carpentry)
	production_rules.append(paint)
	production_rules.append(finish_electrical_work)
	production_rules.append(finish)
	production_rules.append(finish_roofing_flashing)
	production_rules.append(fasten_gutters_downspouts)
	production_rules.append(lay_storm_drains)
	production_rules.append(finish_grading)
	production_rules.append(pour_walks_landscaping)
	production_rules.append(sand_varnish_flooring)
	production_rules.shuffle()
	var possible_types = GraphGrammar.new(
		"ex:constructionGraphGrammar", 
		"gg:GraphGrammar", 
		["start", "Excavate and pour footers", "Pour concrete foundation", "Erect wooden frame including rough roof", "Lay brickwork", "Install basement drains and plumbing", "Pour basement floor", "Install rough plumbing", "Install rough wiring", "Install heating and ventilating", "Fasten plaster board and plaster (including drying)", "Lay finish flooring", "Install kitchen fixtures", "Install finish plumbing", "Finish carpentry", "Paint", "Finish electrical work", "Finish", "Finish roofing and flashing", "Fasten gutters and downspouts", "Lay storm drains for rain water", "Finish grading", "Pour walks and complete landscaping", "Sand and varnish flooring"], 
		["Finish"], 
		["next"], 
		["next"], 
		production_rules,
		"start"
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
	assert_eq_deep(state, { "messages": ["Excavate and pour footers", "Pour concrete foundation", "Erect wooden frame including rough roof", "Lay brickwork", "Install basement drains and plumbing", "Install rough wiring", "Finish roofing and flashing", "Pour basement floor", "Install rough plumbing", "Fasten plaster board and plaster (including drying)", "Fasten gutters and downspouts", "Install heating and ventilating", "Lay finish flooring", "Finish grading", "Install kitchen fixtures", "Install finish plumbing", "Finish carpentry", "Pour walks and complete landscaping", "Paint", "Sand and varnish flooring", "Finish", "Finish electrical work"] }
   )
	assert_eq_deep(result,  [["print_side_effect", "Excavate and pour footers"], ["append_tile_state", "Excavate and pour footers"], ["print_side_effect", "Pour concrete foundation"], ["append_tile_state", "Pour concrete foundation"], ["print_side_effect", "Erect wooden frame including rough roof"], ["append_tile_state", "Erect wooden frame including rough roof"], ["print_side_effect", "Lay brickwork"], ["append_tile_state", "Lay brickwork"], ["print_side_effect", "Install basement drains and plumbing"], ["append_tile_state", "Install basement drains and plumbing"], ["print_side_effect", "Install rough wiring"], ["append_tile_state", "Install rough wiring"], ["print_side_effect", "Finish roofing and flashing"], ["append_tile_state", "Finish roofing and flashing"], ["print_side_effect", "Pour basement floor"], ["append_tile_state", "Pour basement floor"], ["print_side_effect", "Install rough plumbing"], ["append_tile_state", "Install rough plumbing"], ["print_side_effect", "Fasten plaster board and plaster (including drying)"], ["append_tile_state", "Fasten plaster board and plaster (including drying)"], ["print_side_effect", "Fasten gutters and downspouts"], ["append_tile_state", "Fasten gutters and downspouts"], ["print_side_effect", "Install heating and ventilating"], ["append_tile_state", "Install heating and ventilating"], ["print_side_effect", "Lay finish flooring"], ["append_tile_state", "Lay finish flooring"], ["print_side_effect", "Finish grading"], ["append_tile_state", "Finish grading"], ["print_side_effect", "Install kitchen fixtures"], ["append_tile_state", "Install kitchen fixtures"], ["print_side_effect", "Install finish plumbing"], ["append_tile_state", "Install finish plumbing"], ["print_side_effect", "Finish carpentry"], ["append_tile_state", "Finish carpentry"], ["print_side_effect", "Pour walks and complete landscaping"], ["append_tile_state", "Pour walks and complete landscaping"], ["print_side_effect", "Paint"], ["append_tile_state", "Paint"], ["print_side_effect", "Sand and varnish flooring"], ["append_tile_state", "Sand and varnish flooring"], ["print_side_effect", "Finish"], ["append_tile_state", "Finish"], ["print_side_effect", "Finish electrical work"], ["append_tile_state", "Finish electrical work"]]
   )

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

func test_opposite_of_dag():
	var drag_drop_outfit = GraphGrammar.ProductionRule.new("ex:drag_drop_outfit", "gg:Rule", "setup_outfit_prefab", [{"node": "setup_animators", "edge": "next"}])
	var animator_setup = GraphGrammar.ProductionRule.new("ex:animator_setup", "gg:Rule", "setup_animators", [{"node": "after_setup", "edge": "next"}])
	var post_setup = GraphGrammar.ProductionRule.new("ex:post_setup", "gg:Rule", "after_setup", [{"node": "merge_bones", "edge": "next"}])
	var merge_bones = GraphGrammar.ProductionRule.new("ex:merge_bones", "gg:Rule", "merge_bones", [{"node": "setup_bone_proxies", "edge": "next"}])
	var setup_bone_proxies = GraphGrammar.ProductionRule.new("ex:setup_bone_proxies", "gg:Rule", "setup_bone_proxies", [{"node": "setup_cloth_colliders", "edge": "next"}])
	var setup_cloth_colliders = GraphGrammar.ProductionRule.new("ex:setup_cloth_colliders", "gg:Rule", "setup_cloth_colliders", [{"node": "setup_blendshape_sync", "edge": "next"}])
	var setup_blendshape_sync = GraphGrammar.ProductionRule.new("ex:setup_blendshape_sync", "gg:Rule", "setup_blendshape_sync", [{"node": "setup_outfit_prefab", "edge": "next"}]) # This creates a cycle

	var production_rules: Array[GraphGrammar.ProductionRule] = [
		drag_drop_outfit,
		animator_setup,
		post_setup,
		merge_bones,
		setup_bone_proxies,
		setup_cloth_colliders,
		setup_blendshape_sync
	]

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

	var graph = {}
	for rule in production_rules:
		if !graph.has(rule.left_hand_side):
			graph[rule.left_hand_side] = []
		for rhs in rule.right_hand_side:
			if rhs["edge"] == "next":
				graph[rule.left_hand_side].append(rhs["node"])

	assert_true(GraphGrammar.has_cycle(graph))
