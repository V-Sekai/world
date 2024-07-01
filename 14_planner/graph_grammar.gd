extends RefCounted

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
