extends Domain

@export
var keep_fire_burning: Multigoal = Multigoal.new()
@export
var keep_fed: Multigoal = Multigoal.new()
@export
var keep_fed_very_hungry: Multigoal = Multigoal.new()
@export
var calm_down: Multigoal = Multigoal.new()
@export
var relax: Multigoal = Multigoal.new()
@export
var goals: Array

@export
var memory = {
	"firepit_has_fuel": {
		"firepit": true
	},
	"hunger_level": {
		"satyr": "high",
		"priority": 1
	},
	"is_afraid": {
		"satyr": true
	},
	"keep_fire_burning": {
		"priority": 1
	},
	"keep_fed": {
		"priority": 1
	},
	"keep_fed_very_hungry": {
		"priority": 2
	},
	"calm_down": {
		"priority": 10
	},
	"relax": {
		"priority": 0
	}
}

## Initialize the goals and their states
func _init():
	keep_fire_burning.resource_name = "keep_fire_burning"
	keep_fire_burning.state["keep_fire_burning"] = {"priority": 1}
	keep_fire_burning.state["firepit_has_fuel"] = {"firepit": false}
	keep_fed.resource_name = "keep_fed"
	keep_fed.state["keep_fed"] = {"priority": 1}
	keep_fed.state["hunger_level"] = {"priority": 1, "satyr": "low"}
	keep_fed_very_hungry.resource_name = "keep_fed_very_hungry"
	keep_fed_very_hungry.state["keep_fed_very_hungry"] = {"priority": 2}
	keep_fed_very_hungry.state["hunger_level"] = {"satyr": "high"}
	calm_down.resource_name = "calm_down"
	calm_down.state["calm_down"] = {"priority": 10}
	calm_down.state["is_afraid"] = {"satyr": true}  # No priority here
	relax.resource_name = "relax"
	relax.state["relax"] = {"priority": 0}
	goals = [keep_fire_burning, keep_fed, keep_fed_very_hungry, calm_down, relax]
	add_task_methods("behave", [behave])
	add_task_methods("pick_goal", [pick_goal])
	add_task_methods("update_conditions", [update_conditions])
	add_actions([emit, update_firepit_has_fuel, check_hunger_level, update_firepit_has_fuel, update_hunger_level_high, update_hunger_level_low, update_is_afraid])

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
	for predicate in memory.keys():
		for subject in memory[predicate].keys():
			if subject == "priority":
				continue
			var object = memory[predicate][subject]
			match predicate:
				"firepit_has_fuel":
					todo_list.append(["update_firepit_has_fuel", subject, object])
				"hunger_level":
					todo_list.append(["check_hunger_level", subject, object])
				"is_afraid":
					todo_list.append(["update_is_afraid", subject, object])
	return todo_list

func check_hunger_level(memory: Dictionary, subject: String, object: Variant) -> Variant:
	if memory.has("hunger_level"):
		if subject == "priority":
			return false
		if object == "low":
			memory = update_hunger_level_low(memory, subject, "low")
			return memory
		memory = update_hunger_level_high(memory, subject, "high")
		return memory
	return false

func update_firepit_has_fuel(memory: Dictionary, subject: String, object: Variant) -> Variant:
	if subject == "priority":
		return false
	if memory.has("firepit_has_fuel") and memory["firepit_has_fuel"].has(subject) and memory["firepit_has_fuel"][subject] == object:
		memory["firepit_has_fuel"][subject] = true
		# Add additional logic to handle updating firepit fuel status
		return memory
	return false

## Update hunger level to low in memory
func update_hunger_level_low(memory: Dictionary, subject: String, object: Variant) -> Variant:
	if subject == "priority":
		return false
	if memory.has("hunger_level") and memory["hunger_level"].has(subject) and memory["hunger_level"][subject] == object:
		memory["hunger_level"][subject] = "low"
		return memory
	return false

## Update hunger level to high in memory
func update_hunger_level_high(memory: Dictionary, subject: String, object: Variant) -> Variant:
	if subject == "priority":
		return false
	if memory.has("hunger_level") and memory["hunger_level"].has(subject) and memory["hunger_level"][subject] == object:
		memory["hunger_level"][subject] = "high"
		return memory
	return false

## Update fear status in memory
func update_is_afraid(memory: Dictionary, subject: String, object: Variant) -> Variant:
	if memory.has("is_afraid") and memory["is_afraid"].has(subject) and memory["is_afraid"][subject] == object:
		memory["is_afraid"][subject] = true
		# Add additional logic to handle updating fear status
		return memory
	return false
