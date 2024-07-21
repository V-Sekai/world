extends Plan

class_name BehaveOperationalPlan

signal task_completed(result)
var memory = {}
var selected_task

func _on_task_selected(task):
	selected_task = task
	var result = behave(memory, task, Node.new())
	emit_signal("task_completed", result)

# TODO: Implement the character controller so humans and bot entities are equal.
# TODO: Implement the command slot which is a todo_list: Array[Array].
# TODO: Each _process try to complete the current todo_list.
func behave(memory: Dictionary, task: String, satyr: Node) -> Dictionary:
	match task:
		"go_to_firepit":
			return go_to_firepit(memory, satyr)
		"add_wood_to_firepit":
			return add_wood_to_firepit(memory, satyr)
		"find_wood":
			return find_wood(memory, satyr)
		"gather_wood":
			return gather_wood(memory, satyr)
		"find_food":
			return find_food(memory, satyr)
		"gather_food":
			return gather_food(memory, satyr)
		"eat_food":
			return eat_food(memory, satyr)
		"find_safe_spot":
			return find_safe_spot(memory, satyr)
		"go_to_safe_spot":
			return go_to_safe_spot(memory, satyr)
		"find_relax_spot":
			return find_relax_spot(memory, satyr)
		"go_to_relax_spot":
			return go_to_relax_spot(memory, satyr)
		_:
			print("Unknown task: ", task)
			return memory

func go_to_firepit(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to go to the fire pit
	return memory

func add_wood_to_firepit(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to add wood to the fire pit
	memory[["firepit_has_fuel", "firepit"]] = true
	return memory

func find_wood(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to find wood
	return memory

func gather_wood(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to gather wood
	memory[["firepit_has_wood", "firepit"]] = true
	return memory

func find_food(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to find food
	return memory

func gather_food(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to gather food
	memory[["has_food", "satyr"]] = true
	return memory

func eat_food(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to eat food
	memory[["hunger_level", "satyr"]] = max(0, memory.get(["hunger_level", "satyr"], 0) - 5)
	return memory

func find_safe_spot(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to find a safe spot
	return memory

func go_to_safe_spot(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to go to a safe spot
	return memory

func find_relax_spot(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to find a relaxing spot
	return memory

func go_to_relax_spot(memory: Dictionary, satyr: Node) -> Dictionary:
	# Implement the logic to go to a relaxing spot
	return memory
