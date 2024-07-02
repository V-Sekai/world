extends RefCounted

## # Graph Grammars
## Graph grammars extend formal string-based grammars to graphs. We use the algebraic approach, specifically Double-Pushout Graph Grammars (DPO), borrowing terms from category theory.
## **Coding** and **GraphGrammars** are key concepts in this context.
## For more details, refer to the [source](https://liacs.leidenuniv.nl/assets/PDF/TechRep/tr95-34.pdf).
## # Definition 1: EdNCE Grammar
## An **edNCE grammar** is a structured set, or tuple, `G = (Λ, Ξ, Σ, Π, P, S)` where:
## - `Λ` represents the set of all possible node labels,
## - `Ξ`, which is a subset of `Λ`, represents the set of terminal node labels,
## - `Σ` represents the set of all possible edge labels,
## - `Π`, which is a subset of `Σ`, represents the set of final edge labels,
## - `P` is the finite set of production rules,
## - `S` is the initial nonterminal symbol, which belongs to the set difference of `Λ` and `Ξ`.
## A production rule is defined as `X -> (D, C)`, where `X` is a nonterminal symbol that belongs to the set difference of `Λ` and `Ξ`, `D` is a graph over `Λ` and `Σ`, and `C` is a subset of the Cartesian product of `Λ`, `Λ`, `V(D)`, and `fin; outg`.

class GraphGrammar:
	@export var CONTEXT = {
		"gg": "http://v-sekai.com/graphgrammar#",
		"ex": "http://v-sekai.com/ex#"
	}
	@export var id: String = "ex:myGraphGrammar"
	@export var type: String = "gg:GraphGrammar"
	class ProductionRule:
		@export var id: String
		@export var type: String
		@export var left_hand_side: String
		@export var right_hand_side: Array
		func _init(_id: String, _type: String, _left_hand_side: String, _right_hand_side: Array):
			id = _id
			type = _type
			left_hand_side = _left_hand_side
			right_hand_side = _right_hand_side

	@export var node_labels: PackedStringArray
	@export var terminal_node_labels: PackedStringArray
	@export var edge_labels: PackedStringArray
	@export var final_edge_labels: PackedStringArray
	@export var production_rules: Array
	@export var initial_nonterminal_symbol: String
	func all_in_array(subset: PackedStringArray, set: PackedStringArray) -> bool:
		var set_dict = {}
		for element in set:
			set_dict[element] = true

		for element in subset:
			if !set_dict.has(element):
				return false
		return true

	func _init(_id: String, _type: String, _node_labels: PackedStringArray, _terminal_node_labels: PackedStringArray, _edge_labels: PackedStringArray, _final_edge_labels: PackedStringArray, _production_rules: Array[ProductionRule], _initial_nonterminal_symbol: String):
		# Initialize with valid but non-empty default values
		id = _id if _id != "" else "default_id"
		type = _type if _type != "" else "default_type"
		node_labels = _node_labels if not _node_labels.is_empty() else PackedStringArray(["default_node_label"])
		terminal_node_labels = _terminal_node_labels if not _terminal_node_labels.is_empty() else PackedStringArray(["default_terminal_node_label"])
		edge_labels = _edge_labels if not _edge_labels.is_empty() else PackedStringArray(["default_edge_label"])
		final_edge_labels = _final_edge_labels if not _final_edge_labels.is_empty() else PackedStringArray(["default_final_edge_label"])
		production_rules = _production_rules if not _production_rules.is_empty() else [ProductionRule.new("default_production_rule_id", "default_rule_type", "default_left_hand_side", [])]
		initial_nonterminal_symbol = _initial_nonterminal_symbol if not _initial_nonterminal_symbol.is_empty() else "default_initial_nonterminal_symbol"

		if !all_in_array(_terminal_node_labels, _node_labels):
			push_error("All terminal node labels must be in the set of all possible node labels.")
			return
		if !all_in_array(_final_edge_labels, _edge_labels):
			push_error("All final edge labels must be in the set of all possible edge labels.")
			return
		if _terminal_node_labels.has(_initial_nonterminal_symbol):
			push_error("The initial nonterminal symbol must not be a terminal node label.")
			return
		for rule in _production_rules:
			if !_node_labels.has(rule.left_hand_side):
				push_error("The left-hand side of each production rule must be a possible node label.")
				return
			for rhs in rule.right_hand_side:
				if !_node_labels.has(rhs["node"]):
					push_error("Each node in the right-hand side of each production rule must be a possible node label.")
					return
				if !_edge_labels.has(rhs["edge"]):
					push_error("Each edge in the right-hand side of each production rule must be a possible edge label.")
					return

		# If no errors, set the actual values
		id = _id
		type = _type
		node_labels = _node_labels
		terminal_node_labels = _terminal_node_labels
		edge_labels = _edge_labels
		final_edge_labels = _final_edge_labels
		production_rules = _production_rules
		initial_nonterminal_symbol = _initial_nonterminal_symbol


static func plan_to_graph_grammar(todo_list: Array, state: Dictionary) -> GraphGrammar:
	var node_labels = PackedStringArray()
	var terminal_node_labels = PackedStringArray()
	var edge_labels = PackedStringArray(["next"])
	var final_edge_labels = PackedStringArray(["next"])
	var production_rules: Array[GraphGrammar.ProductionRule]
	var initial_nonterminal_symbol = todo_list[0][0]
	
	var node_labels_dict = {}
	for i in range(todo_list.size()):
		var node = todo_list[i][0]
		var possible_tiles = state[i]["possible_tiles"]

		# Add the node label to the list of all possible node labels
		if !node_labels_dict.has(node):
			node_labels.append(node)
			node_labels_dict[node] = true

		# If this is the last node in the todo list, add it to the list of terminal node labels
		# Exclude the initial nonterminal symbol from being added to terminal node labels
		if i == todo_list.size() - 1 and node != initial_nonterminal_symbol:
			terminal_node_labels.append(node)

		# For each possible tile, create a production rule from the current node to that tile
		for tile in possible_tiles:
			# Add the tile to the list of all possible node labels if it's not already there
			if !node_labels_dict.has(tile):
				node_labels.append(tile)
				node_labels_dict[tile] = true

			var rule = GraphGrammar.ProductionRule.new("ex:rule" + str(i), "gg:Rule", node, [{"node": tile, "edge": "next"}])
			production_rules.append(rule)

	var graph_grammar = GraphGrammar.new("ex:myGraphGrammar", "gg:GraphGrammar", node_labels, terminal_node_labels, edge_labels, final_edge_labels, production_rules, initial_nonterminal_symbol)
	return graph_grammar
