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
	const CONTEXT = {
		"gg": "http://v-sekai.com/graphgrammar#",
		"ex": "http://v-sekai.com/ex#"
	}
	var id: String = "ex:myGraphGrammar"
	var type: String = "gg:GraphGrammar"
	var initialized: bool = false

	class ProductionRule:
		var id: String
		var type: String
		var left_hand_side: String
		var right_hand_side: Array
		func _init(_id: String, _type: String, _left_hand_side: String, _right_hand_side: Array):
			self.id = _id
			self.type = _type
			self.left_hand_side = _left_hand_side
			self.right_hand_side = _right_hand_side

	var node_labels: PackedStringArray
	var terminal_node_labels: PackedStringArray
	var edge_labels: PackedStringArray
	var final_edge_labels: PackedStringArray
	var production_rules: Array[ProductionRule]
	var initial_nonterminal_symbol: String
	func all_in_array(subset: PackedStringArray, set: PackedStringArray) -> bool:
		var set_dict = {}
		for element in set:
			set_dict[element] = true

		for element in subset:
			if !set_dict.has(element):
				return false
		return true
	func _init(_id: String, _type: String, _node_labels: PackedStringArray, _terminal_node_labels: PackedStringArray, _edge_labels: PackedStringArray, _final_edge_labels: PackedStringArray, _production_rules: Array[ProductionRule], _initial_nonterminal_symbol: String):
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

		self.id = _id
		self.type = _type
		self.node_labels = _node_labels
		self.terminal_node_labels = _terminal_node_labels
		self.edge_labels = _edge_labels
		self.final_edge_labels = _final_edge_labels
		self.production_rules = _production_rules
		self.initial_nonterminal_symbol = _initial_nonterminal_symbol
		self.initialized = true

static func plan_to_graph_grammar(todo_list: Array, state: Dictionary) -> Dictionary:
	var graph_grammar = {
		"@context": {
			"gg": "http://v-sekai.com/graphgrammar#",
			"ex": "http://v-sekai.com/ex#"
		},
		"@id": "ex:myGraphGrammar",
		"@type": "gg:GraphGrammar",
		"gg:nodeLabels": [],
		"gg:terminalNodeLabels": [],
		"gg:edgeLabels": ["next"],
		"gg:finalEdgeLabels": ["next"],
		"gg:productionRules": [],
		"gg:initialNonterminalSymbol": todo_list[0][0]
	}

	for i in range(todo_list.size()):
		var node = todo_list[i][0]
		var possible_tiles = state[i]["possible_tiles"]

		# Add the node label to the list of all possible node labels
		if !graph_grammar["gg:nodeLabels"].has(node):
			graph_grammar["gg:nodeLabels"].append(node)

		# If this is the last node in the todo list, add it to the list of terminal node labels
		if i == todo_list.size() - 1:
			graph_grammar["gg:terminalNodeLabels"].append(node)

		# For each possible tile, create a production rule from the current node to that tile
		for tile in possible_tiles:
			var rule = {
				"@id": "ex:rule" + str(i),
				"@type": "gg:Rule",
				"gg:leftHandSide": node,
				"gg:rightHandSide": [{"node": tile, "edge": "next"}]
			}
			graph_grammar["gg:productionRules"].append(rule)

	return graph_grammar
