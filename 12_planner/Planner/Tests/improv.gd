extends Domain

class_name Improv

@export var possible_types: GraphGrammar = null

func _init() -> void:
	add_actions([append_tile_state, print_side_effect])
	add_task_methods("apply_graph_grammar_node", [apply_graph_grammar_node])
	add_task_methods("behave", [behave])

func append_tile_state(state: Dictionary, chosen_tile) -> Dictionary:
	if state.has("is_tile") and state["is_tile"] is Array:
		state["is_tile"].append(chosen_tile)
	return state

func apply_graph_grammar_node(_state, object) -> Variant:
	return [["print_side_effect", object], ["set_tile_state", object]]

static func print_side_effect(state, message) -> Dictionary:
	if not state.has("messages"):
		state["messages"] = []
	state["messages"].append(message)
	return state

func behave(_state, current_nodes = null, completed_actions = {}, plan = []):
	if current_nodes == null:
		current_nodes = [possible_types.initial_nonterminal_symbol]

	var node_to_rule = {}
	for rule in possible_types.production_rules:
		var lhs = rule.left_hand_side
		if not node_to_rule.has(lhs):
			node_to_rule[lhs] = []
		node_to_rule[lhs].append(rule)

	if current_nodes.is_empty():
		return plan

	var next_nodes = []
	for current_node in current_nodes:
		if node_to_rule.has(current_node):
			var rules = node_to_rule[current_node]
			for rule in rules:
				for action in rule.right_hand_side:
					var action_key = str(action["node"])
					if not completed_actions.has(action_key):
						plan.append(["print_side_effect", action["node"]])
						plan.append(["append_tile_state", action["node"]])
						completed_actions[action_key] = true
						next_nodes.append(action["node"])

	return [["behave", next_nodes, completed_actions, plan]]
