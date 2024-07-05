extends Domain

@export
var wander: Multigoal = Multigoal.new()
@export
var goals: Array

@export
var memory = {
		"wander": {"priority": 0}
	}

## Initialize the goals and their states
func _init():
	wander.resource_name = "wander"
	wander.state["wander"] = memory["wander"]
	goals = [wander]
	add_task_methods("behave", [behave])
	add_task_methods("pick_goal", [pick_goal])
	add_task_methods("update_conditions", [update_conditions])
	add_actions([emit,])

func emit(memory, multigoal):
	if multigoal  as Multigoal == null:
		return false
	for key in multigoal.state:
		memory[key].merge(multigoal.state[key])
	return memory

func behave(_memory: Dictionary) -> Variant:
	return [["pick_goal"]]

## Function to pick the highest priority goal based on memory
func pick_goal(memory: Dictionary) -> Variant:
	var highest_priority = -1
	var selected_goal: Multigoal = null
	for goal in goals:
		var all_conditions_met = true
		for state_key in goal.state.keys():
			var condition = {state_key: goal.state[state_key]}
			if not conditions_met(memory, condition):
				all_conditions_met = false
				break
		
		if all_conditions_met:
			var priority = goal.state[goal.resource_name].get("priority", -1)
			print_verbose("Checking goal: ", goal.resource_name, " with priority: ", priority)
			
			if priority > highest_priority:
				print_verbose("Conditions met for goal: ", goal.resource_name)
				highest_priority = priority
				selected_goal = goal
		else:
			print_verbose("Conditions not met for goal: ", goal.resource_name)
	
	if selected_goal != null:
		print_verbose("Selected goal: ", selected_goal.resource_name)
		#emit_signal("goal_selected", selected_goal)
		return [["emit", selected_goal]]
	else:
		print_verbose("No goal selected")
		return []

## Helper function to check if all conditions are met
func conditions_met(memory: Dictionary, condition: Dictionary) -> bool:
	for predicate in condition.keys():
		if predicate == "priority":
			continue
		var subject = condition[predicate].keys()[0]
		var expected_value = condition[predicate][subject]
		if predicate not in memory or subject not in memory[predicate] or memory[predicate][subject] != expected_value:
			print_verbose("Condition not met:", predicate, "expected:", expected_value, "found:", memory.get(predicate, {}).get(subject, "not found"))
			return false
		print_verbose("Condition met:", predicate, "expected:", expected_value, "found:", memory.get(predicate, {}).get(subject, "not found"))
	return true


## Update memory with the perception and messages.
func update_conditions(memory: Dictionary) -> Variant:
	var todo_list: Array[Array] = []
	return todo_list
