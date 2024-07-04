extends Plan

class_name BehaveSquadPlanner

## Plan specific actions based on the assigned task
func plan_task(task: String, memory: Dictionary) -> Array:
	match task:
		"keep_fire_burning":
			return plan_keep_fire_burning(memory)
		"keep_fed":
			return plan_keep_fed(memory)
		"calm_down":
			return plan_calm_down(memory)
		"relax":
			return plan_relax(memory)
		_:
			return []

## Task-specific plans
func plan_keep_fire_burning(memory: Dictionary) -> Array:
	if memory.get(["firepit_has_wood", "firepit"], false):
		return ["go_to_firepit", "add_wood_to_firepit"]
	else:
		return ["find_wood", "gather_wood", "go_to_firepit", "add_wood_to_firepit"]

func plan_keep_fed(memory: Dictionary) -> Array:
	if memory.get(["has_food", "satyr"], false):
		return ["eat_food"]
	else:
		return ["find_food", "gather_food", "eat_food"]

func plan_calm_down(memory: Dictionary) -> Array:
	return ["find_safe_spot", "go_to_safe_spot"]

func plan_relax(memory: Dictionary) -> Array:
	return ["find_relax_spot", "go_to_relax_spot"]
