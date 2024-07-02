extends "res://addons/gut/test.gd"

func test_simple_avatar():
	var buy_stuff = GraphGrammar.ProductionRule.new("BuyStuff", "gg:Rule", "buy_stuff", [{"node": "Buy items for the user.", "edge": "next"}])
	var upload_stuff = GraphGrammar.ProductionRule.new("UploadStuff", "gg:Rule", "upload_stuff", [{"node": "Upload the purchased items.", "edge": "next"}])
	var kitbash = GraphGrammar.ProductionRule.new("Kitbash", "gg:Rule", "kitbash", [{"node": "Kitbash the uploaded items.", "edge": "next"}])
	var download_to_user = GraphGrammar.ProductionRule.new("DownloadToUser", "gg:Rule", "download_to_user", [{"node": "Download the kitbashed items to the user.", "edge": "next"}])

	var production_rules = [buy_stuff, upload_stuff, kitbash, download_to_user]

	var state = {}
	var planner = Plan.new()
	planner.current_domain = Improv.new()
	planner.current_domain.possible_types = GraphGrammar.new(
		"ex:mySimpleGraphGrammar", 
		"gg:GraphGrammar", 
		["buy_stuff", "upload_stuff", "kitbash", "download_to_user", "end"], 
		["end"], 
		["next"], 
		["next"], 
		production_rules,
		"buy_stuff"
	)
	
	assert_false(not production_rules.is_empty())    
	
	for i in range(4):
		var possible_tiles = []
		for graph in planner.current_domain.possible_types.node_labels:
			possible_tiles.append(graph)
		state[i] = { "tile": null, "possible_tiles": possible_tiles }
	
	var todo_list = [["meta_collapse_wave_function"]]
	planner.verbose = 0
	
	gut.p("Todo list: ", todo_list)
	gut.p("State: ", state)
	gut.p("Graph Grammar: ")
	
	var result = planner.find_plan(state, todo_list)
	
	gut.p("Result: ", result)
	gut.p("State: ", state)
	
	assert_eq_deep(result, [["set_tile_state", 0, "buy_stuff"], ["set_tile_state", 1, "upload_stuff"], ["set_tile_state", 2, "kitbash"], ["set_tile_state", 3, "download_to_user"]])
