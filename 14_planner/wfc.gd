extends Node3D

# Function to calculate entropy of a square
func _calculate_entropy(square) -> int:
	return len(square["possible_tiles"])

# Function to find the square with the lowest entropy
func _find_lowest_entropy_square(state) -> Variant:
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
	
	if len(min_squares) == 0:
		return null
	
	var chosen_key = min_squares[0]
	return chosen_key

const possible_types = {
	"sea_1": {
		"below": ["coast_1", "coast_2"],
		"left": ["sea_2", "sea_3", "sea_4", "coast_1", "coast_3"],
		"right": ["sea_2", "sea_3", "sea_4", "coast_1", "coast_3"],
		"above": ["sea_2", "sea_3", "sea_4", "coast_1", "coast_3"]
	},
	"sea_2": {
		"below": ["coast_1", "coast_2"],
		"left": ["sea_1", "sea_3", "sea_4", "coast_1", "coast_3"],
		"right": ["sea_1", "sea_3", "sea_4", "coast_1", "coast_3"],
		"above": ["sea_1", "sea_3", "sea_4", "coast_1", "coast_3"]
	},
	"sea_3": {
		"below": ["coast_1", "coast_2"],
		"left": ["sea_1", "sea_2", "sea_4", "coast_1", "coast_3"],
		"right": ["sea_1", "sea_2", "sea_4", "coast_1", "coast_3"],
		"above": ["sea_1", "sea_2", "sea_4", "coast_1", "coast_3"]
	},
	"sea_4": {
		"below": ["coast_1", "coast_2"],
		"left": ["sea_1", "sea_2", "sea_3", "coast_1", "coast_3"],
		"right": ["sea_1", "sea_2", "sea_3", "coast_1", "coast_3"],
		"above": ["sea_1", "sea_2", "sea_3", "coast_1", "coast_3"]
	},
	"coast_1": {
		"below": ["land_1", "land_2"],
		"left": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_2", "coast_3"],
		"right": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_2", "coast_3"],
		"above": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_2", "coast_3"]
	},
	"coast_2": {
		"below": ["land_1", "land_2"],
		"left": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_3"],
		"right": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_3"],
		"above": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_3"]
	},
	"coast_3": {
		"below": ["land_1", "land_2"],
		"left": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_2"],
		"right": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_2"],
		"above": ["sea_1", "sea_2", "sea_3", "sea_4", "coast_1", "coast_2"]
	},
	"land_1": {
		"below": ["coast_1", "coast_2", "coast_3"],
		"left": ["coast_1", "coast_2", "coast_3", "land_2"],
		"right": ["coast_1", "coast_2", "coast_3", "land_2"],
		"above": ["coast_1", "coast_2", "coast_3"]
	},
	"land_2": {
		"below": ["coast_1", "coast_2", "coast_3"],
		"left": ["coast_1", "coast_2", "coast_3", "land_1"],
		"right": ["coast_1", "coast_2", "coast_3", "land_1"],
		"above": ["coast_1", "coast_2", "coast_3"]
	}
}

var direction_names = ["above", "below", "left", "right"]

const tile_width = 2

func set_tile_state(state, coordinate, chosen_tile) -> Dictionary:
	if state.has(coordinate) and typeof(state[coordinate]) == TYPE_DICTIONARY:
		state[coordinate]["tile"] = chosen_tile
		if state[coordinate]["possible_tiles"].has(chosen_tile):
			state[coordinate]["possible_tiles"].erase(chosen_tile)
	return state

func remove_possible_tile(state, coordinate, chosen_tile) -> Dictionary:
	if state.has(coordinate):
		if state[coordinate].has("possible_tiles"):
			var possible_tiles = state[coordinate]["possible_tiles"]
			var index_of_chosen_tile = possible_tiles.find(chosen_tile)
			if index_of_chosen_tile != -1:
				possible_tiles.remove(index_of_chosen_tile)
	return state


func update_possible_tiles(state, key, chosen_tile):
	var x = key % tile_width
	var y = key / tile_width

	var directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]
	var todos = []
	var set_tiles = []
	for direction in directions:
		var nx = x + direction[0]
		var ny = y + direction[1]
		if tile_width != 1:
			nx = (nx + tile_width) % tile_width
			ny = (ny + tile_width) % tile_width

		var neighbor_key = ny * tile_width + nx
		if tile_width == 1:
			todos.append(["set_tile_state", neighbor_key, chosen_tile])
			todos.append(["remove_possible_tile", neighbor_key, chosen_tile])
			return

		if neighbor_key in state and "possible_tiles" in state[neighbor_key]:
			var neighbor_possible_tiles = state[neighbor_key]["possible_tiles"]
			
			if chosen_tile in neighbor_possible_tiles:
				var new_possible_tiles = []
				for tile in neighbor_possible_tiles:
					if tile != chosen_tile:
						new_possible_tiles.append(tile)
				if new_possible_tiles.size() > 0: 
					if neighbor_key not in set_tiles:
						todos.append(["set_tile_state", neighbor_key, chosen_tile])
						set_tiles.append(neighbor_key)
		todos.append(["remove_possible_tile", neighbor_key, chosen_tile])
	return todos

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

func collapse_wave_function(state: Dictionary) -> Variant:
	var key = _find_lowest_entropy_square(state)
	
	if key == null:
		if all_tiles_have_state(state):
			return []
		else:
			print("Contradiction found, restarting...")
			return false
	
	var possible_tiles = state[key]["possible_tiles"]
	
	for chosen_tile in possible_tiles:
		var actions = [["set_tile_state", key, chosen_tile]]
		return actions

	print("No valid tile choices for key ", key, ", restarting...")
	return false

## Meta collapse_wave_function
func meta_collapse_wave_function(state):
	if all_tiles_have_state(state):
		return []
	else:
		var new_state = state.duplicate()  # Create a copy of the state to try collapse_wave_function
		new_state = collapse_wave_function(new_state)
		
		if new_state:
			return [["collapse_wave_function"], ["meta_collapse_wave_function"]]
		else:
			print("Contradiction found in meta_collapse_wave_function, restarting...")
			return [["meta_collapse_wave_function"]]

func print_ascii_art(state, width):
	var ascii_art = ""
	for i in range(width):
		for j in range(width):
			if state[i * width + j]["tile"] != null:
				# Use the first letter of the tile type as its symbol
				var symbol = state[i * width + j]["tile"]
				ascii_art += symbol
			else:
				ascii_art += "null"
			ascii_art += " "
		ascii_art += "\n"
	print(ascii_art)


func _ready() -> void:
	var planner: Plan = Plan.new()
	var the_domain: Domain = Domain.new()
	planner.current_domain = the_domain

	the_domain.add_actions([set_tile_state, remove_possible_tile])
	the_domain.add_task_methods("collapse_wave_function", [collapse_wave_function])
	the_domain.add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])
	the_domain.add_task_methods("update_possible_tiles", [update_possible_tiles])

	planner.current_domain = the_domain
	planner.verbose = 1

	var state = {}
	for i in range(tile_width):
		for j in range(tile_width):
			state[i * tile_width + j] = {
				"tile": null,
				"possible_tiles": possible_types.keys()
			}
	#var middle_key = (tile_width * tile_width) / 2
	#state[middle_key] = {
	#"tile": "land_1",
	#"possible_tiles": ["land_1"]
	#}
	var wfc_array: Array
	for i in range(tile_width * tile_width):
		wfc_array.append(["meta_collapse_wave_function"])
	var result = planner.find_plan(state, wfc_array)
	print_ascii_art(state, tile_width)
