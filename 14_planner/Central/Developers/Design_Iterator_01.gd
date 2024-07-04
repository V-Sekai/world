extends "res://addons/gut/test.gd"

# One city district Immerssive Simulation Game. 
# Moped Racer: A coming-of-age story takes place in Neon Meadows, a futuristic city powered by holographic tech. Here, solar energy fuels the high-tech mascot companions used for transportation and delivery services. Elite couriers train hard to become skilled riders known as Moped Racers. Join Aria on her journey to join this prestigious group while uncovering an unexpected mystery in a world filled with neon lights and advanced technology!
# 3 choices per menu level.

func test_ready() -> void:
	var planner = Plan.new()
	planner.current_domain = Domain.new()
	var state: Dictionary
	state["landmarks"] = [
		"cafe", 
		"cafe_parking", 
		"old_town_hall", 
		"ancient_fortress_ruins", 
		"grand_national_park", 
		"modern_art_gallery", 
		"city_history_museum", 
		"traditional_market_square", 
		"old_cathedral", 
		"skyline_tower_observation_deck",
		"aria_home",
		"tech_hub", 
		"green_rooftop_garden",
		"virtual_reality_museum",
		"central_park_lakefront_cafe",]
	state["vehicles"] = ["moped"]
	state["characters"] = ["Aria"]
	state["vehicle_contains"] = {"moped": "Aria"}
	state["player_is"] = {"selected": "Aria"}
	state["player_at"] = {"Aria": "cafe_parking"}
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
