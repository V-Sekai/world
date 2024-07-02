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
	for i in range(7):
		var possible_tiles = []
		for graph in improv.possible_types.node_labels:
			possible_tiles.append(graph)
		state[i] = { "tile": null, "possible_tiles": possible_tiles }
	var todo_list: Array = [["meta_collapse_wave_function"]]
	var planner = Plan.new()
	planner.current_domain = Improv.new()
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
