extends Domain

class_name Improv

@export var possible_types: GraphGrammar = null

func _init() -> void:
	add_actions([set_tile_state, print_side_effect])
	add_task_methods("apply_graph_grammar_node", [apply_graph_grammar_node])
	add_task_methods("solve_graph_grammar", [solve_graph_grammar])

func set_tile_state(state: Dictionary, coordinate, chosen_tile) -> Dictionary:
	if state.has("has_possible_tiles") and state["has_possible_tiles"].has(coordinate):
		state["has_possible_tiles"][coordinate] = [chosen_tile]
	if state.has("is_tile") and state["is_tile"].has(coordinate):
		state["is_tile"][coordinate] = chosen_tile
	return state

func apply_graph_grammar_node(state, predicate, subject, object) -> Variant:
	return [["print_side_effect", object], ["set_tile_state", subject, object]]

static func print_side_effect(state, message) -> Dictionary:
	if not state.has("messages"):
		state["messages"] = []
	state["messages"].append(message)
	return state

func solve_graph_grammar(state):
	var plan = []
	var current_nodes = [possible_types.initial_nonterminal_symbol]
	var completed_actions = {}
	var node_to_rule = {}
	
	for rule in possible_types.production_rules:
		var lhs = rule.left_hand_side
		if not node_to_rule.has(lhs):
			node_to_rule[lhs] = []
		node_to_rule[lhs].append(rule)
	
	while current_nodes.size() > 0:
		var next_nodes = []
		for current_node in current_nodes:
			if node_to_rule.has(current_node):
				for rule in node_to_rule[current_node]:
					for action in rule.right_hand_side:
						var action_key = str(action["node"])
						if not completed_actions.has(action_key):
							plan.append(["print_side_effect", action["node"]])
							plan.append(["set_tile_state", plan.size() / 2, action["node"]])
							completed_actions[action_key] = true
							next_nodes.append(action["node"])
		current_nodes = next_nodes
	
	return plan
