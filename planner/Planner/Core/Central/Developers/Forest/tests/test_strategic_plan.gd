extends "res://addons/gut/test.gd"

@onready var strategic_plan = preload("res://Central/Developers/Forest/StrategicPlan.gd").new()

func test_pick_goal():
	strategic_plan.current_domain = preload("res://Central/Developers/Forest/SatyrStrategicDomain.gd").new()
	strategic_plan.verbose = 3
	var todo_list = strategic_plan.current_domain.pick_goal(strategic_plan.current_domain.memory)
	gut.p(todo_list)
	assert_eq(todo_list.size(), 1)
	var selected_goal = todo_list[0][1]
	assert_eq(selected_goal.resource_name, "calm_down", "Expected 'calm_down', got %s" % selected_goal)

	strategic_plan.current_domain = preload("res://Central/Developers/Forest/SatyrStrategicDomain.gd").new()
	strategic_plan.current_domain.memory["is_afraid"]["satyr"] = false
	todo_list = strategic_plan.current_domain.pick_goal(strategic_plan.current_domain.memory)
	assert_eq(todo_list.size(), 1)
	selected_goal = todo_list[0][1]
	assert_eq(selected_goal.resource_name, "keep_fed_very_hungry", "Expected 'keep_fed_very_hungry', got %s" % selected_goal)

	strategic_plan.current_domain = preload("res://Central/Developers/Forest/SatyrStrategicDomain.gd").new()
	strategic_plan.current_domain.memory["hunger_level"]["satyr"] = "low"
	strategic_plan.current_domain.memory["is_afraid"]["satyr"] = false
	todo_list = strategic_plan.current_domain.pick_goal(strategic_plan.current_domain.memory)
	assert_eq(todo_list.size(), 1)
	selected_goal = todo_list[0][1]
	assert_eq(selected_goal.resource_name, "keep_fed", "Expected 'keep_fed', got %s" % selected_goal)

	strategic_plan.current_domain = preload("res://Central/Developers/Forest/SatyrStrategicDomain.gd").new()
	strategic_plan.current_domain.memory["hunger_level"]["satyr"] = "low"
	strategic_plan.current_domain.memory["is_afraid"]["satyr"] = false
	todo_list = strategic_plan.find_plan(strategic_plan.current_domain.memory, [["behave"]])
	assert_eq_deep(todo_list[0][1], strategic_plan.current_domain.keep_fed)
