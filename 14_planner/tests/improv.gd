extends Domain

class_name Improv

# https://robertheaton.com/2018/12/17/wavefunction-collapse-algorithm/

@export var possible_types: GraphGrammar = null

func _init() -> void:
	add_actions([set_tile_state, print_side_effect])
	add_task_methods("apply_graph_grammar_node", [apply_graph_grammar_node])
	add_task_methods("collapse_wave_function", [collapse_wave_function])
	add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])
	
# Function to calculate entropy of a square
static func _calculate_entropy(square) -> int:
	return len(square["possible_tiles"])


static func _find_lowest_entropy_square(state) -> Variant:
	var min_entropy = INF
	var min_squares = []
	
	for key in state["has_possible_tiles"]:
		var possible_tiles = state["has_possible_tiles"][key]
		if len(possible_tiles) <= 1: # Skip if the square is solved
			continue
		var entropy = len(possible_tiles)
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

## Function to find the square with the lowest entropy
func calculate_square(state):
	return _find_lowest_entropy_square(state)

# Function to check if all tiles have a state
func all_tiles_have_state(state: Dictionary) -> bool:
	for key in state.keys():
		if key.begins_with("is_tile"):
			for sub_key in state[key].keys():
				if state[key][sub_key] == null:
					return false
		elif key.begins_with("has_possible_tiles"):
			for sub_key in state[key].keys():
				if typeof(state[key][sub_key]) != TYPE_ARRAY or state[key][sub_key].is_empty():
					return false
	return true


func set_tile_state(state: Dictionary, coordinate, chosen_tile) -> Dictionary:
	if state["has_possible_tiles"].has(coordinate):
		state["has_possible_tiles"][coordinate] = [chosen_tile]
	if state["is_tile"].has(coordinate):
		state["is_tile"][coordinate] = chosen_tile
	return state

func collapse_wave_function(state: Dictionary) -> Array:
	var result = [[]]
	var key = _find_lowest_entropy_square(state)

	if key == null:
		if all_tiles_have_state(state):
			return []
		else:
			return []

	var possible_tiles: Array = state["has_possible_tiles"][key]
	var chosen_tile = null

	# If this is the first tile, choose a starting tile
	if key == 0:
		chosen_tile = possible_types.initial_nonterminal_symbol
	else:
		# Otherwise, choose a tile based on the previous tile and the graph grammar rules
		var previous_tile = state["is_tile"][key - 1]
		for rule in possible_types.production_rules:
			if rule.left_hand_side in previous_tile:
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
		rng.seed = rng_seed
		chosen_tile = custom_shuffle(possible_tiles, rng).front()

	possible_tiles.erase(chosen_tile)
	result.front().append("apply_graph_grammar_node")
	result.front().append("is_tile")
	result.front().append(key)
	result.front().append(chosen_tile)
	return result

func apply_graph_grammar_node(state, predicate, subject, object) -> Variant:
	return [["print_side_effect", object], ["set_tile_state", subject, object]]


static func print_side_effect(state, message) -> Dictionary:
	print(message)
	return state


func meta_collapse_wave_function(state):
	var old_state = state["is_tile"].duplicate()  # Save the old is_tile for comparison
	for key in state["has_possible_tiles"]:
		if state["has_possible_tiles"][key].size() == 0:
			return []
	if not all_tiles_have_state(state):
		var todo_list = [["collapse_wave_function"]]
		todo_list.append(["meta_collapse_wave_function"])
		return todo_list
	elif state["is_tile"] == old_state:  # If the is_tile hasn't changed, stop the recursion
		return []
	else:
		var possible_tiles = []
		for graph in possible_types["gg:nodeLabels"]:
			possible_tiles.append(graph)
		state["has_possible_tiles"][0] = possible_tiles  # Set the first tile's possible tiles
		state["is_tile"][0] = null  # Set the first tile to null
		
		# Remove null states if 'end' is found
		for key in state["is_tile"]:
			if state["is_tile"][key] in possible_types.terminal_node_labels:  # Check for 'end' symbol
				var new_state = { "has_possible_tiles": {}, "is_tile": {} }
				for k in state["is_tile"].keys():
					if state["is_tile"][k] != null:
						new_state["has_possible_tiles"][k] = state["has_possible_tiles"][k]
						new_state["is_tile"][k] = state["is_tile"][k]
				state.clear()  # Clear the original state
				state.update(new_state)  # Update the original state with the new state
				break

	# Check conditions again before recursive call
	if all_tiles_have_state(state) or state["is_tile"] == old_state:
		return []
	else:
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
