extends "res://addons/gut/test.gd"

func feed_pet(p_state, p_pet, p_food):
	p_state["hunger"][p_pet] -= p_food["nutrition"]
	return p_state

func give_water(p_state, p_pet, p_water):
	p_state["thirst"][p_pet] -= p_water["hydration"]
	return p_state

func walk_pet(p_state, p_pet):
	p_state["exercise"][p_pet] += 1
	return p_state

func release_pet(p_state, p_pet):
	p_state["location"][p_pet] = "neighborhood"
	return p_state

func pet_pet(p_state, p_pet):
	p_state["happiness"][p_pet] += 10
	return p_state

func play_with_pet(p_state, p_pet):
	p_state["happiness"][p_pet] += 20
	p_state["exercise"][p_pet] += 5
	return p_state

func train_pet(p_state, p_pet):
	p_state["intelligence"][p_pet] += 1
	return p_state

func method_feed_pet(p_state, p_pet, p_hunger):
	if p_pet in p_state["pets"] and p_state["hunger"][p_pet] < 5:
		return [[p_pet, "nutrition", 5], ["hunger", p_pet, 5]]
	return false

func method_give_water(p_state, p_pet, p_thirst):
	if p_pet in p_state["pets"] and p_state["thirst"][p_pet] > 5:
		return [[p_pet, "hydration", 5]]
	return false

func method_exercise_pet(p_state, p_pet, p_exercise):
	if p_pet in p_state["pets"] and p_state["exercise"][p_pet] < 5:
		return [["location", p_pet, "neighborhood"], ["walk_pet", p_pet], ["exercise", p_pet, 5],]
	return false

func method_release_pet(p_state, p_pet, p_location):
	if p_pet in p_state["pets"] and p_location in p_state["locations"] and p_state["location"][p_pet] != "neighborhood":
		return [["release_pet", p_pet]]
	return false

func task_care_for_pet(p_state, p_pet):
	var goals: Dictionary = p_state.duplicate(true)
	if p_state["hunger"][p_pet] > 5:
		goals["nutrition"][p_pet] = 5
	if p_state["thirst"][p_pet] > 5:
		goals["hydration"][p_pet] = 5
	if p_state["exercise"][p_pet] < 5:
		goals["exercise"][p_pet] = 5
	if p_state["location"][p_pet] != "neighborhood":
		goals["location"][p_pet] = "neighborhood"
	var multigoal = Multigoal.new()
	multigoal.resource_name = "multigoal_care_for_pet"
	multigoal.state = goals
	return [multigoal]

func test_ready() -> void:
	var planner: Plan = Plan.new()
	var the_domain: Domain = Domain.new()

	the_domain.add_task_methods("care_for_pet", [task_care_for_pet])
	the_domain.add_task_methods("walk_pet", [walk_pet])
	the_domain.add_task_methods("release_pet", [release_pet])
	the_domain.add_unigoal_methods("hunger", [method_feed_pet])
	the_domain.add_unigoal_methods("thirst", [method_give_water])
	the_domain.add_unigoal_methods("location", [method_release_pet])
	the_domain.add_unigoal_methods("exercise", [method_exercise_pet])
	the_domain.add_actions([feed_pet, give_water, walk_pet, release_pet])
	planner.current_domain = the_domain
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
