extends Node3D

# Function to calculate entropy of a square
func _calculate_entropy(square):
	return len(square["possible_tiles"])

# Function to find the square with the lowest entropy
func _find_lowest_entropy_square(state):
	var min_entropy = INF
	var min_squares = []
	for key in state:
		var square = state[key]
		if len(square["possible_tiles"]) <= 1: # Skip if the square is solved
			continue
		var entropy = _calculate_entropy(square)
		if entropy < min_entropy:
			min_entropy = entropy
			min_squares = [key]
		elif entropy == min_entropy:
			min_squares.append(key)
	print_verbose("Min entropy: ", min_entropy)
	print_verbose("Min squares: ", min_squares)
	
	if len(min_squares) == 0:
		return null
	
	var chosen_key = min_squares[randi() % len(min_squares)]
	print_verbose("Chosen key: ", chosen_key)
	return chosen_key

const possible_types: Dictionary = {
	"sea": {
		"below": ["coast"],
		"left": ["coast", "sea"],
		"right": ["coast", "sea"],
		"above": ["coast", "sea"]
	},
	"coast": {
		"left": ["land", "sea", "coast"],
		"right": ["land", "sea", "coast"],
		"above": ["sea"],
		"below": ["land"]
	},
	"land": {
		"left": ["coast", "land"],
		"right": ["coast", "land"],
		"above": ["coast"],
		"below": ["coast"]
	},
}

var direction_names = ["above", "below", "left", "right"]

func set_tile_state(state, key, chosen_tile):
	if key != null:
		state[key]["tile"] = chosen_tile
		state[key]["possible_tiles"] = [chosen_tile]
		update_possible_tiles(state, key, chosen_tile)
	return state

const tile_width = 4

func update_possible_tiles(state, key, chosen_tile):
	var x = key % tile_width
	var y = key / tile_width

	# Adjusted directions to account for wrapping around
	var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]

	for i in range(len(directions)):
		var direction = directions[i]
		var nx = (x + direction[0] + 4) % 4  # Wrap around horizontally
		var ny = (y + direction[1] + 4) % 4  # Wrap around vertically

		var neighbor_key = ny * tile_width + nx

		var neighbor_possible_tiles = state[neighbor_key]["possible_tiles"]
		var allowed_tiles = possible_types[chosen_tile][direction_names[i]]

		var new_possible_tiles = []
		for tile in neighbor_possible_tiles:
			if tile in allowed_tiles:
				new_possible_tiles.append(tile)

		# Only update the neighbor's possible tiles if there are any left
		if len(new_possible_tiles) > 0:
			# If new_possible_tiles is exactly the same as neighbor_possible_tiles, return []
			var is_tile_same = true
			if new_possible_tiles.size() == neighbor_possible_tiles.size():
				for new_tile in new_possible_tiles:
					if neighbor_possible_tiles.find(new_tile) == -1:
						is_tile_same = false
						break
			else:
				is_tile_same = false

			if is_tile_same:
				return state
			else:
				state[neighbor_key]["possible_tiles"] = new_possible_tiles
		else:
			print_verbose("Contradiction found, restarting...")
			return false
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
	
func set_single_possible_state(state):
	for key in state.keys():
		var tile = state[key]
		if len(tile["possible_tiles"]) == 1:
			set_tile_state(state, key, tile["possible_tiles"][0])
	return state

func collapse_wave_function(state):
	var key = _find_lowest_entropy_square(state)
	
	if key == null:
		if all_tiles_have_state(state):
			return []
		else:
			print("Contradiction found, restarting...")
			return false
	
	var possible_tiles = state[key]["possible_tiles"]
	
	if possible_tiles.size() > 0:
		var chosen_tile = possible_tiles[0]
		var actions = [["set_tile_state", key, chosen_tile], ["update_possible_tiles", key, chosen_tile]]
		return actions
	else:
		return [[collapse_wave_function]]

## Meta collapse_wave_function
func meta_collapse_wave_function(state):
	if all_tiles_have_state(state):
		return []
	else:
		var new_state = state.duplicate()  # Create a copy of the state to try collapse_wave_function
		new_state = collapse_wave_function(new_state)
		
		if new_state:
			return [["collapse_wave_function"], ["set_single_possible_state"]]
		else:
			print("Contradiction found in meta_collapse_wave_function, restarting...")
			return [["meta_collapse_wave_function"]]

func print_ascii_art(state, width):
	var ascii_art = ""
	for i in range(width):
		for j in range(width):
			if state[i * width + j]["tile"] != null:
				# Use the first letter of the tile type as its symbol
				var symbol = state[i * width + j]["tile"][0]
				ascii_art += symbol
			else:
				ascii_art += "n"
			ascii_art += " "
		ascii_art += "\n"
	print(ascii_art)


func _ready() -> void:
	var planner: Plan = Plan.new()
	var the_domain: Domain = Domain.new()
	planner.current_domain = the_domain

	the_domain.add_actions([set_tile_state, update_possible_tiles, set_single_possible_state])
	the_domain.add_task_methods("collapse_wave_function", [collapse_wave_function])
	the_domain.add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])

	planner.current_domain = the_domain
	planner.verbose = 1

	var state = {}
	for i in range(tile_width):
		for j in range(tile_width):
			state[i * tile_width + j] = {
				"tile": null,
				"possible_tiles": possible_types.keys()
			}

	var wfc_array: Array
	for i in tile_width * tile_width:
		wfc_array.append(["meta_collapse_wave_function"])
	var result = planner.find_plan(state, wfc_array)
	print(result)
	print_ascii_art(state, tile_width)
