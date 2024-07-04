extends Plan

func _init():
	var keep_fire_burning: Multigoal = Multigoal.new()
	keep_fire_burning.state["keep_fire_burning"].merge({"priority": 1})
	keep_fire_burning.state["firepit_has_fuel"].merge({"firepit": false})

	var keep_fed: Multigoal = Multigoal.new()
	keep_fed.state["keep_fed"].merge({"priority": 1})
	keep_fed.state["hunger_level"].merge({"priority": 1})
	keep_fed.state["hunger_level"].merge({"satyr": "low"})

	var keep_fed_very_hungry: Multigoal = Multigoal.new()
	keep_fed_very_hungry.state["keep_fed_very_hungry"].merge({"priority": 2})
	keep_fed_very_hungry.state["hunger_level"].merge({"satyr": "high"})

	var calm_down: Multigoal = Multigoal.new()
	calm_down.state["calm_down"].merge({"priority": 10})
	calm_down.state["is_afraid"].merge({"satyr": true})

	var relax: Multigoal = Multigoal.new()
	relax.state["relax"].merge({"priority": 0})

## Assign a task based on the highest priority goal
func assign_task(memory: Dictionary) -> String:
	var task = "relax"
	var highest_priority = 0
	for goal in goals.keys():
		var condition: Array = goals[goal]["condition"]
		var predicate = condition[0]
		var subject = condition[1]
		var object = condition[2]
		memory[predicate].merge({subject: object})
		if check_condition(predicate, subject, object, memory):
			if goals[goal]["priority"] > highest_priority:
				highest_priority = goals[goal]["priority"]
				task = goal
	return task

## Check if a condition is met for a given goal
func daemon_check_condition(predicate: String, subject: String, object: Variant, memory: Dictionary) -> bool:
	match predicate:
		"firepit_has_fuel":
			return memory.get([predicate, subject], false) == object
		"hunger_level":
			var hunger_level = memory.get(["hunger_level", subject], 0)
			return (object == "low" and hunger_level > 5 and hunger_level <= 10) or (object == "high" and hunger_level > 10)
		"is_afraid":
			return memory.get([predicate, subject], false) == object
		"none":
			return true
		_:
			return false
