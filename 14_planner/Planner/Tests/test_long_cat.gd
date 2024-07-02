extends "res://addons/gut/test.gd"

func test_ready() -> void:
	var planner: Plan = Plan.new()
	planner.current_domain = LongCatDomain.new()
	planner.verbose = 0

	var state: Dictionary = {
		"pets": ["longcat"],
		"locations": ["home", "neighborhood"],
		"hunger": {"longcat": 10},
		"thirst": {"longcat": 10},
		"exercise": {"longcat": 0},
		"location": {"longcat": "home"},
		"nutrition": {"longcat": 6},
		"hydration": {"longcat": 6},
		"health": {"longcat": 100},
		"happiness": {"longcat": 50},
	}

	var task: Array = [["care_for_pet", "longcat"]]
	var result = planner.find_plan(state, task)
	gut.p(result)
	assert_eq_deep(result, [["release_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"]])
