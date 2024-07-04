extends "res://addons/gut/test.gd"

# The right number of choices is the number that feels like you cover what the players will want to answer.
# Brune

func test_ready() -> void:
	var planner = Plan.new()
	planner.current_domain = Domain.new()
	var state: Dictionary
	state["landmarks"] = ["package1", "package2"]
	state["vehicles"] = ["moped"]
	state["players"] = ["player"]
    state["vehicle_contains"] = {"moped": "player"}
	state["player_at"] = {"player": "cafe_parking"}
	planner.verbose = 0
	var gameplay_tasks: Array = [
		["unravel", "game_storyline"],  
		["learn_about_landmarks", "central_district"],
		["travel", "key_locations"]  , 
		["choose_quest_templates", "basic"],   
		["apply", "character_control"],	
		["choose", "player_interaction"],  
	]
	var task: Array = gameplay_tasks
	var plan: Variant = planner.find_plan(state, task)
	assert_eq_deep(plan, [])
