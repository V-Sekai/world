extends Domain

class_name Improv

@export var possible_types: GraphGrammar = null

func _init() -> void:
	add_actions([append_tile_state, print_side_effect])
	add_task_methods("apply_graph_grammar_node", [apply_graph_grammar_node])
	add_task_methods("solve_graph_grammar", [solve_graph_grammar])
	add_task_methods("process_rule", [process_rule])

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

func solve_graph_grammar(_state):
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
				var rules = node_to_rule[current_node]
				for rule in rules:
					var sub_plan = process_rule(_state, rule, completed_actions, next_nodes)
					plan += sub_plan
		current_nodes = next_nodes

	return plan

func process_rule(_state, rule, completed_actions, next_nodes):
	var plan = []
	for action in rule.right_hand_side:
		var action_key = str(action["node"])
		if not completed_actions.has(action_key):
			plan.append(["print_side_effect", action["node"]])
			plan.append(["append_tile_state", action["node"]])
			completed_actions[action_key] = true
			next_nodes.append(action["node"])
	return plan
