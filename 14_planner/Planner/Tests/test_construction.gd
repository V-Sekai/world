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
