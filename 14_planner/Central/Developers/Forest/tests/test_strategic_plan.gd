extends "res://addons/gut/test.gd"

@onready var strategic_plan = preload("res://Central/Developers/Forest/StrategicPlan.gd").new()

func test_pick_goal():
	var memory = {
		"firepit_has_fuel": {"firepit": false},
		"hunger_level": {"satyr": "high"},
		"is_afraid": {"satyr": true}
	}

	# Test picking the highest priority goal
	var selected_goal = strategic_plan.pick_goal(memory)
	assert_eq(selected_goal, "calm_down", "Expected 'calm_down', got %s" % selected_goal)

	# Modify memory to change the expected goal
	memory["is_afraid"]["satyr"] = false
	selected_goal = strategic_plan.pick_goal(memory)
	assert_eq(selected_goal, "keep_fed_very_hungry", "Expected 'keep_fed_very_hungry', got %s" % selected_goal)

	# Further modify memory to change the expected goal again
	memory["hunger_level"]["satyr"] = "low"
	selected_goal = strategic_plan.pick_goal(memory)
	assert_eq(selected_goal, "keep_fed", "Expected 'keep_fed', got %s" % selected_goal)
