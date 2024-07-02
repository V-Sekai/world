extends "res://addons/gut/test.gd"

var wfc: RefCounted

class Improv extends Domain:
	# https://robertheaton.com/2018/12/17/wavefunction-collapse-algorithm/
	
	@export var possible_types = null

	func _init() -> void:
		add_actions([set_tile_state, remove_possible_tiles])
		add_task_methods("collapse_wave_function", [collapse_wave_function])
		add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])
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
		possible_types = GraphGrammar.new(
			"ex:myGraphGrammar", 
			"gg:GraphGrammar", 
			["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"], 
			["end"], 
			["next"], 
			["next"], 
			production_rules,
			"root"
		)
		
	# Function to calculate entropy of a square
	static func _calculate_entropy(square) -> int:
		return len(square["possible_tiles"])

	static func _find_lowest_entropy_square(state) -> Variant:
		var min_entropy = INF
		var min_squares = []
		for key in state:
			var square = state[key]
			if len(square["possible_tiles"]) <= 1: # Skip if the square is solved
				continue
			var entropy = len(square["possible_tiles"])
			if entropy < min_entropy:
				min_entropy = entropy
				min_squares = [key]
			elif entropy == min_entropy:
				min_squares.append(key)
		
		if len(min_squares) == 0:
			return null
		
		var chosen_key = min_squares[0]
		return chosen_key

	var rng_seed = hash("Godot Engine")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()

	func custom_shuffle(array: Array, rng: RandomNumberGenerator) -> Array:
		var n = array.size()
		while n > 1:
			n -= 1
			var k = rng.randi() % (n + 1)
			var value = array[k]
			array[k] = array[n]
			array[n] = value
		return array

	static func array_difference(a1: Array, a2: Array) -> Array:
		var diff = []
		for element in a1:
			if element not in a2:
				diff.append(element)
		return diff

	func collapse_wave_function(state: Dictionary) -> Array:
		var result = [["set_tile_state"]]
		var key = _find_lowest_entropy_square(state)

		if key == null:
			if all_tiles_have_state(state):
				return []
			else:
				return []

		var possible_tiles: Array = state[key]["possible_tiles"]
		var chosen_tile = null

		# If this is the first tile, choose a starting tile
		if key == 0:
			chosen_tile = "root"
		else:
			# Otherwise, choose a tile based on the previous tile and the graph grammar rules
			var previous_tile = state[key - 1]["tile"]
			for rule in possible_types.production_rules:
				if rule.left_hand_side == previous_tile:
					rng.seed = rng_seed
					rule.right_hand_side = custom_shuffle(rule.right_hand_side, rng)
					for node in rule.right_hand_side:
						if node['node'] in possible_tiles:
							chosen_tile = node['node']
							break
					if chosen_tile != null:
						break

		if chosen_tile == null:
			# If no valid tile was found, choose a random tile
			chosen_tile = possible_tiles[0]

		possible_tiles.erase(chosen_tile)
		result[0].append(key)
		result[0].append(chosen_tile)
		return result

	func set_tile_state(state, coordinate, chosen_tile) -> Dictionary:
		if state.has(coordinate):
			state[coordinate]["tile"] = chosen_tile
			state[coordinate]["possible_tiles"] = [chosen_tile]
		return state

	func remove_possible_tiles(state, coordinate, chosen_tiles: Array) -> Dictionary:
		if state.has(coordinate):
			if state[coordinate].has("possible_tiles"):
				var possible_tiles = state[coordinate]["possible_tiles"]
				for tile in chosen_tiles:
					possible_tiles.erase(tile)
		return state

	## Function to find the square with the lowest entropy
	func calculate_square(state):
		return _find_lowest_entropy_square(state)

	# Function to check if all tiles have a state
	func all_tiles_have_state(state):
		for key in state:
			var square = state[key]
			if square["tile"] == null or len(square["possible_tiles"]) != 1: # If a square's tile is null or doesn't have exactly one possible tile, it doesn't have a state yet
				return false
		return true
		
	func meta_collapse_wave_function(state):
		var old_state = state.duplicate()  # Save the old state for comparison
		for key in state:
			if 'type' in state[key] and state[key]['type'] == "gg:initialNonterminalSymbol":
				return []
		if not all_tiles_have_state(state):
			var todo_list = [["collapse_wave_function"]]
			todo_list.append(["meta_collapse_wave_function"])
			return todo_list
		elif old_state == state:  # If the state hasn't changed, stop the recursion
			return []
		else:
			var possible_tiles = []
			for graph in possible_types["gg:nodeLabels"]:
				possible_tiles.append(graph)
			state[0] = { "tile": null, "possible_tiles": possible_tiles }
			
			# Remove null states if 'end' is found
			for key in state:
				if state[key]['tile'] == "gg:initialNonterminalSymbol":
					var new_state = {}
					for k in state.keys():
						if state[k]['tile'] != null:
							new_state[k] = state[k]
					state = new_state
					break
			return [["meta_collapse_wave_function"]]


	func is_valid_sequence(state: Dictionary) -> bool:
		# Convert the gg:GraphGrammar.ProductionRules array into a dictionary for easier access
		var possible_types_dict = {}
		for rule in possible_types["gg:GraphGrammar.ProductionRules"]:
			var item_id = rule["@id"]
			var next_items = []
			for node in rule["gg:rightHandSide"]:
				next_items.append(node['node'])
			possible_types_dict[item_id] = next_items

		print("Possible types dict: ", possible_types_dict)

		var keys = state.keys()
		for i in range(keys.size() - 1):
			var currentType = state[keys[i]]["tile"]
			if currentType != null:
				var nextType = state[keys[i + 1]]["tile"]
				if nextType != null:
					print("Current type: ", currentType)
					print("Next type: ", nextType)
					if not possible_types_dict.has(currentType):
						print("Current type not in possible types dict")
						return false
					elif not possible_types_dict[currentType].has(nextType):
						print("Next type not in current type's list")
						return false
		return true


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
	planner.current_domain = wfc
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
