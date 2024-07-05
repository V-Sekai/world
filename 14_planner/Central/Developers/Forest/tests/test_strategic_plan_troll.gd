extends "res://addons/gut/test.gd"

@onready var strategic_plan = preload("res://Central/Developers/Forest/StrategicPlan.gd").new()

func test_pick_goal():
	strategic_plan.current_domain = preload("res://Central/Developers/Forest/TrollStrategicDomain.gd").new()
	strategic_plan.verbose = 3
	var todo_list = strategic_plan.current_domain.pick_goal(strategic_plan.current_domain.memory)
	gut.p(todo_list)
	assert_eq(todo_list.size(), 1)
	var selected_goal = todo_list[0][1]
	assert_eq(selected_goal.resource_name, "wander", "Expected 'calm_down', got %s" % selected_goal)
