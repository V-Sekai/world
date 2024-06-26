extends Domain

# https://robertheaton.com/2018/12/17/wavefunction-collapse-algorithm/

func _init() -> void:
	add_actions([set_tile_state, remove_possible_tiles])
	add_task_methods("collapse_wave_function", [collapse_wave_function])
	add_task_methods("meta_collapse_wave_function", [meta_collapse_wave_function])
	add_task_methods("update_possible_tiles", [update_possible_tiles])

# Function to calculate entropy of a square
func _calculate_entropy(square) -> int:
	return len(square["possible_tiles"])

func _find_lowest_entropy_square(state) -> Variant:
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

const possible_types = {
  "@context": {
	"next": "http://v-sekai.com/wfc-next"
  },
  "@graph": [
	{
	  "@id": "root",
	  "next": ["Bob", "Alice", "Carol"]
	},
	{
	  "@id": "Bob",
	  "next": [": I have a"]
	},
	{
	  "@id": "Alice",
	  "next": [": I have a"],
	  "tags": [["class", "mammal"]]
	},
	{
	  "@id": "Carol",
	  "next": [": I have a"],
	  "tags": [["class", "bird"]]
	},
	{
	  "@id": ": I have a",
	  "next": ["dog", "cat", "parrot"]
	},
	{
	  "@id": "dog",
	  "next": ["who is"],
	  "tags": [["class", "mammal"]]
	},
	{
	  "@id": "cat",
	  "next": ["who is"],
	  "tags": [["class", "mammal"]]
	},
	{
	  "@id": "parrot",
	  "next": ["who is"],
	  "tags": [["class", "bird"]]
	},
	{
	  "@id": "who is",
	  "next": ["2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old."]
	},
	{
	  "@id": "2 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "3 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "4 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "5 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "6 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "7 years old.",
	  "next": ["end"]
	},
	{
	  "@id": "end",
	  "next": []
	}
  ]
}

var direction_names = ["next"];

static func array_difference(a1: Array, a2: Array) -> Array:
	var diff = []
	for element in a1:
		if element not in a2:
			diff.append(element)
	return diff

func update_possible_tiles(state, coordinates, chosen_tile):
	var todos = []
	if state.has(coordinates) and "possible_tiles" in state[coordinates]:
		var possible_tiles = state[coordinates]["possible_tiles"]
		var difference = array_difference(possible_tiles, possible_types[chosen_tile]["next"])
		todos.append(["remove_possible_tiles", coordinates, difference])
		todos.append(["set_tile_state", coordinates, possible_tiles])
	return todos


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

func collapse_wave_function(state: Dictionary) -> Variant:
	var result = [["set_tile_state"]]
	var key = _find_lowest_entropy_square(state)
	
	if key == null:
		if all_tiles_have_state(state):
			return []
		else:
			return false
	
	var possible_tiles: Array = state[key]["possible_tiles"]
	possible_tiles.shuffle()
		
	# Ensure the chosen tile is valid
	var chosen_tile = null
	for tile in possible_tiles:
		if key > 0:
			var prev_tile = state[key - 1]["tile"]
			for graph in possible_types["@graph"]:
				if graph["@id"] == prev_tile:  # Look for @id that matches prev_tile
					if tile in graph["next"]:  # Check if tile is in its next array
						chosen_tile = tile
						break
			if chosen_tile != null:
				break
		else:
			for graph in possible_types["@graph"]:
				if graph["@id"] == "root" and tile in graph["next"]:
					chosen_tile = tile
					break
			if chosen_tile != null:
				break
	
	possible_tiles.erase(chosen_tile)
	result[0].append(key)
	result[0].append(chosen_tile)
	return result

## Meta collapse_wave_function
func meta_collapse_wave_function(state):
	if all_tiles_have_state(state):
		return []
	else:
		var todo_list = [["collapse_wave_function"]]
		todo_list.append(["meta_collapse_wave_function"])
		return todo_list

func is_valid_sequence(state: Dictionary) -> bool:
	# Convert the @graph array into a dictionary for easier access
	var possible_types_dict = {}
	for i in range(possible_types["@graph"].size() - 1):
		var item = possible_types["@graph"][i]
		possible_types_dict[item["@id"]] = item["next"]

	var keys = state.keys()
	for i in range(keys.size() - 1):
		var currentType = state[keys[i]]["tile"]
		if currentType != null:
			var nextType = state[keys[i + 1]]["tile"]
			if nextType != null and not possible_types_dict[currentType].has(nextType):
				return false
	return true
