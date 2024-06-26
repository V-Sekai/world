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

# # Graph Grammars
# Graph grammars extend formal string-based grammars to graphs. We use the algebraic approach, specifically Double-Pushout Graph Grammars (DPO), borrowing terms from category theory.
# **Coding** and **GraphGrammars** are key concepts in this context.
# For more details, refer to the [source](https://liacs.leidenuniv.nl/assets/PDF/TechRep/tr95-34.pdf).
# # Definition 1: EdNCE Grammar
# An **edNCE grammar** is a structured set, or tuple, `G = (Λ, Ξ, Σ, Π, P, S)` where:
# - `Λ` represents the set of all possible node labels,
# - `Ξ`, which is a subset of `Λ`, represents the set of terminal node labels,
# - `Σ` represents the set of all possible edge labels,
# - `Π`, which is a subset of `Σ`, represents the set of final edge labels,
# - `P` is the finite set of production rules,
# - `S` is the initial nonterminal symbol, which belongs to the set difference of `Λ` and `Ξ`.
# A production rule is defined as `X -> (D, C)`, where `X` is a nonterminal symbol that belongs to the set difference of `Λ` and `Ξ`, `D` is a graph over `Λ` and `Σ`, and `C` is a subset of the Cartesian product of `Λ`, `Λ`, `V(D)`, and `fin; outg`.

const possible_types = {
  "@context": {
	"gg": "http://v-sekai.com/graphgrammar#",
	"ex": "http://v-sekai.com/ex#"
  },
  "@id": "ex:myGraphGrammar",
  "@type": "gg:GraphGrammar",
  "gg:nodeLabels": ["root", "Bob", "Alice", "Carol", ": I have a", "dog", "cat", "parrot", "who is", "2 years old.", "3 years old.", "4 years old.", "5 years old.", "6 years old.", "7 years old.", "end"],
  "gg:terminalNodeLabels": ["end"],
  "gg:edgeLabels": ["next"],
  "gg:finalEdgeLabels": ["next"],
  "gg:productionRules": [
	{
	  "@id": "ex:rule1",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "root",
	  "gg:rightHandSide": [{"node": "Bob", "edge": "next"}, {"node": "Alice", "edge": "next"}, {"node": "Carol", "edge": "next"}]
	},
	{
	  "@id": "ex:rule2",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "Bob",
	  "gg:rightHandSide": [{"node": ": I have a", "edge": "next"}]
	},
	{
	  "@id": "ex:rule3",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "Alice",
	  "gg:rightHandSide": [{"node": ": I have a", "edge": "next"}]
	},
	{
	  "@id": "ex:rule4",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "Carol",
	  "gg:rightHandSide": [{"node": ": I have a", "edge": "next"}]
	},
	{
	  "@id": "ex:rule5",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": ": I have a",
	  "gg:rightHandSide": [{"node": "dog", "edge": "next"}, {"node": "cat", "edge": "next"}, {"node": "parrot", "edge": "next"}]
	},
	{
	  "@id": "ex:rule6",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "dog",
	  "gg:rightHandSide": [{"node": "who is", "edge": "next"}]
	},
	{
	  "@id": "ex:rule7",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "cat",
	  "gg:rightHandSide": [{"node": "who is", "edge": "next"}]
	},
	{
	  "@id": "ex:rule8",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "parrot",
	  "gg:rightHandSide": [{"node": "who is", "edge": "next"}]
	},
	{
	  "@id": "ex:rule9",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "who is",
	  "gg:rightHandSide": [{"node": "2 years old.", "edge": "next"}, {"node": "3 years old.", "edge": "next"}, {"node": "4 years old.", "edge": "next"}, {"node": "5 years old.", "edge": "next"}, {"node": "6 years old.", "edge": "next"}, {"node": "7 years old.", "edge": "next"}]
	},
	{
	  "@id": "ex:rule10",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "2 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	},
	{
	  "@id": "ex:rule11",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "3 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	},
	{
	  "@id": "ex:rule12",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "4 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	},
	{
	  "@id": "ex:rule13",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "5 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	},
	{
	  "@id": "ex:rule14",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "6 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	},
	{
	  "@id": "ex:rule15",
	  "@type": "gg:Rule",
	  "gg:leftHandSide": "7 years old.",
	  "gg:rightHandSide": [{"node": "end", "edge": "next"}]
	}
  ],
  "gg:initialNonterminalSymbol": "root"
}

func update_possible_tiles(state, coordinates, chosen_tile):
	var todos = []
	
	# Return early if chosen_tile is null
	if chosen_tile == null:
		return todos

	if state.has(coordinates) and "possible_tiles" in state[coordinates]:
		var possible_tiles = state[coordinates]["possible_tiles"]
		
		# Find the right-hand side nodes for the chosen tile
		var next_nodes = []
		for rule in possible_types["gg:productionRules"]:
			if rule["gg:leftHandSide"] == chosen_tile:
				for node in rule["gg:rightHandSide"]:
					next_nodes.append(node['node'])
				break
		
		var difference = array_difference(possible_tiles, next_nodes)
		
		# Remove the tiles that are not in the next nodes
		for tile in difference:
			possible_tiles.erase(tile)
		
		todos.append(["remove_possible_tiles", coordinates, difference])
		todos.append(["set_tile_state", coordinates, possible_tiles])
	return todos

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
		for rule in possible_types["gg:productionRules"]:
			if rule["gg:leftHandSide"] == previous_tile:
				for node in rule["gg:rightHandSide"]:
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
	# Convert the gg:productionRules array into a dictionary for easier access
	var possible_types_dict = {}
	for rule in possible_types["gg:productionRules"]:
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
