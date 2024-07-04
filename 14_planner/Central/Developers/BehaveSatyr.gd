extends CharacterBody3D

class_name Satyr

## Define the memory dictionary
var memory = {
	["firepit_has_fuel", "firepit"]:false,
	["firepit_has_wood", "firepit"]:false,
	["hunger_level", "satyr"]:0,
	["has_food", "satyr"]:false,
	["is_afraid", "satyr"]:false
}

## Update the memory states
func update_memory() -> void:
	update_firepit_has_fuel()
	update_hunger_state()
	update_afraid_state()

func update_firepit_has_fuel() -> void:
	memory[["firepit_has_fuel", "firepit"]] = false # Replace with actual logic

func update_hunger_state() -> void:
	var hunger_level: int
	memory[["hunger_level", "satyr"]] = hunger_level
	memory[["has_food", "satyr"]] = memory[["hunger_level", "satyr"]] > 5 and memory[["hunger_level", "satyr"]] <= 10
	memory[["has_food", "satyr"]] = memory[["hunger_level", "satyr"]] > 10

func update_afraid_state() -> void:
	memory[["is_afraid", "satyr"]] = get_distance_to_troll() < 5

## Check if the Satyr is afraid
func get_distance_to_troll() -> float:
	return 10 # Replace with actual distance calculation

func go_to_firepit() -> void:
	## Implement the logic to go to the fire pit
	pass

func add_wood_to_firepit() -> void:
	## Implement the logic to add wood to the fire pit
	memory[["firepit_has_fuel", "firepit"]] = true
	pass

func find_wood() -> void:
	## Implement the logic to find wood
	pass

func gather_wood() -> void:
	## Implement the logic to gather wood
	memory[["firepit_has_wood", "firepit"]] = true
	pass

func find_food() -> void:
	## Implement the logic to find food
	pass

func gather_food() -> void:
	## Implement the logic to gather food
	memory[["has_food", "satyr"]] = true
	pass
