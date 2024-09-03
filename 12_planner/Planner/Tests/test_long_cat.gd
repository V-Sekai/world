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

	var pet = "longcat";
	var goals: Dictionary = state.duplicate(true)
	if goals["hunger"][pet] > 5:
		goals["nutrition"][pet] = 5
	if goals["thirst"][pet] > 5:
		goals["hydration"][pet] = 5
	if goals["exercise"][pet] < 5:
		goals["exercise"][pet] = 5
	if goals["location"][pet] != "neighborhood":
		goals["location"][pet] = "neighborhood"
	var multigoal = Multigoal.new()
	multigoal.resource_name = "multigoal_care_for_pet"
	multigoal.state = goals
	var result = planner.find_plan(state, [multigoal])
	gut.p(result)
	assert_eq_deep(result, [["release_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"], ["walk_pet", "longcat"]])
