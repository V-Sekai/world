extends Node

func drive_truck(p_state, p_truck, p_location):
	p_state["truck_at"][p_truck] = p_location
	return p_state

func fly_plane(p_state, p_plane, p_airport):
	p_state["plane_at"][p_plane] = p_airport
	return p_state

func load_truck(p_state, p_object, p_truck):
	p_state["at"][p_object] = p_truck
	return p_state

func load_plane(p_state, p_object, p_plane):
	p_state["at"][p_object] = p_plane
	return p_state

func unload_plane(p_state, p_object, p_airport):
	var plane = p_state["at"][p_object]
	if p_state["plane_at"][plane] == p_airport:
		p_state["at"][p_object] = p_airport
	return p_state

func unload_truck(p_state, p_object, p_location):
	var truck = p_state["at"][p_object]
	if p_state["truck_at"][truck] == p_location:
		p_state["at"][p_object] = p_location
	return p_state

# Helper functions for the methods.

func _find_truck(p_state, p_object):
	for truck in p_state["trucks"]:
		if p_state["in_city"][p_state["truck_at"][truck]] == p_state["in_city"][p_state["at"][p_object]]:
			return truck
	return false

func _find_plane(p_state, p_object):
	var last_plane
	for plane in p_state["airplanes"]:
		if p_state["in_city"][p_state["plane_at"][plane]] == p_state["in_city"][p_state["at"][p_object]]:
			return plane
		last_plane = plane
	return last_plane

func _find_airport(p_state, p_location):
	for airport in p_state["airports"]:
		if p_state["in_city"][airport] == p_state["in_city"][p_location]:
			return airport
	return false

# Other methods

func method_drive_truck(p_state, p_truck, p_location):
	if p_truck in p_state["trucks"] and p_location in p_state["locations"] and p_state["in_city"][p_state["truck_at"][p_truck]] == p_state["in_city"][p_location]:
		return [["drive_truck", p_truck, p_location]]
	return false

func method_load_truck(p_state, p_object, p_truck):
	if p_object in p_state["packages"] and p_truck in p_state["trucks"] and p_state["at"][p_object] == p_state["truck_at"][p_truck]:
		return [["load_truck", p_object, p_truck]]
	return false

func method_unload_truck(p_state, p_object, p_location):
	if p_object in p_state["packages"] and p_state["at"][p_object] in p_state["trucks"] and p_location in p_state["locations"]:
		return [["unload_truck", p_object, p_location]]
	return false

func method_fly_plane(p_state, p_plane, p_airport):
	if p_plane in p_state["airplanes"] and p_airport in p_state["airports"]:
		return [["fly_plane", p_plane, p_airport]]
	return false

func method_load_plane(p_state, p_object, p_plane):
	if p_object in p_state["packages"] and p_plane in p_state["airplanes"] and p_state["at"][p_object] == p_state["plane_at"][p_plane]:
		return [["load_plane", p_object, p_plane]]
	return false

func method_unload_plane(p_state, p_object, p_airport):
	if p_object in p_state["packages"] and p_state["at"][p_object] in p_state["airplanes"] and p_airport in p_state["airports"]:
		return [["unload_plane", p_object, p_airport]]
	return false

func method_move_within_city(p_state, p_object, p_location):
	if p_object in p_state["packages"] and p_state["at"][p_object] in p_state["locations"] and p_state["in_city"][p_state["at"][p_object]] == p_state["in_city"][p_location]:
		var truck = _find_truck(p_state, p_object)
		if truck:
			return [["truck_at", truck, p_state["at"][p_object]], ["at", p_object, truck], ["truck_at", truck, p_location], ["at", p_object, p_location]]
	return false

func method_move_between_airports(p_state, p_object, p_airport):
	if p_object in p_state["packages"] and p_state["at"][p_object] in p_state["airports"] and p_airport in p_state["airports"] and p_state["in_city"][p_state["at"][p_object]] != p_state["in_city"][p_airport]:
		var plane = _find_plane(p_state, p_object)
		if plane:
			return [["plane_at", plane, p_state["at"][p_object]], ["at", p_object, plane], ["plane_at", plane, p_airport], ["at", p_object, p_airport]]
	return false

func method_move_between_city(p_state, p_object, p_location):
	if p_object in p_state["packages"] and p_state["at"][p_object] in p_state["locations"] and p_state["in_city"][p_state["at"][p_object]] != p_state["in_city"][p_location]:
		var airport_1 = _find_airport(p_state, p_state["at"][p_object])
		var airport_2 = _find_airport(p_state, p_location)
		if airport_1 and airport_2:
			return [["at", p_object, airport_1], ["at", p_object, airport_2], ["at", p_object, p_location]]
	return false

func before_each(p_state, p_planner, p_the_domain):
	assert(p_planner != null)
	assert(p_the_domain != null)
	p_planner.set_verbose(0)
	p_state.clear()
	var domains = []
	domains.append(p_the_domain)
	p_planner.set_domains(domains)

	p_planner.set_current_domain(p_the_domain)
	var actions: Array[Callable] = [drive_truck, load_truck, unload_truck, fly_plane, load_plane, unload_plane]
	p_the_domain.add_actions(actions)

	var truck_at_methods: Array[Callable] = [method_drive_truck]
	p_the_domain.add_unigoal_methods("truck_at", truck_at_methods)

	var plane_at_methods: Array[Callable] = [method_fly_plane]
	p_the_domain.add_unigoal_methods("plane_at", plane_at_methods)

	var at_methods: Array[Callable] = [method_load_truck, method_unload_truck, method_load_plane, method_unload_plane]
	p_the_domain.add_unigoal_methods("at", at_methods)

	var move_methods: Array[Callable] = [method_move_within_city, method_move_between_airports, method_move_between_city]
	p_the_domain.add_unigoal_methods("at", move_methods)

	p_state["packages"] = ["package1", "package2"]
	p_state["trucks"] = ["truck1", "truck6"]
	p_state["airplanes"] = ["plane2"]
	p_state["locations"] = ["airport1", "location1", "location2", "location3", "airport2", "location10"]
	p_state["airports"] = ["airport1", "airport2"]
	p_state["cities"] = ["city1", "city2"]

	p_state["at"] = {"package1": "location1", "package2": "location2"}
	p_state["truck_at"] = {"truck1": "location3", "truck6": "location10"}
	p_state["plane_at"] = {"plane2": "airport2"}

	p_state["in_city"] = {
		"airport1": "city1",
		"location1": "city1",
		"location2": "city1",
		"location3": "city1",
		"airport2": "city2",
		"location10": "city2"
	}
@export
var planner: Plan 

@export
var the_domain: Domain 

@export
var state1: Dictionary 

func _ready() -> void:
	planner = Plan.new()
	the_domain = Domain.new()
	planner.current_domain = the_domain
	before_each(state1, planner, the_domain)
	planner.verbose = 1
	var task: Array = [["at", "package1", "location10"]]
	var plan: Variant = planner.find_plan(state1, task)
	print(plan)
	# [["drive_truck", "truck1", "location1"], ["load_truck", "package1", "truck1"], ["drive_truck", "truck1", "airport1"], ["unload_truck", "package1", "airport1"], ["fly_plane", "plane2", "airport1"], ["load_plane", "package1", "plane2"], ["fly_plane", "plane2", "airport2"], ["unload_plane", "package1", "airport2"], ["drive_truck", "truck6", "airport2"], ["load_truck", "package1", "truck6"], ["drive_truck", "truck6", "location10"], ["unload_truck", "package1", "location10"]]
