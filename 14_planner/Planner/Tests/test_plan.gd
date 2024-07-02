extends "res://addons/gut/test.gd"

@export
var planner: Plan 

@export
var state: Dictionary 

func test_ready() -> void:
	planner = Plan.new()
	planner.current_domain = LogisticsDomain.new()
	state["packages"] = ["package1", "package2"]
	state["trucks"] = ["truck1", "truck6"]
	state["airplanes"] = ["plane2"]
	state["locations"] = ["airport1", "location1", "location2", "location3", "airport2", "location10"]
	state["airports"] = ["airport1", "airport2"]
	state["cities"] = ["city1", "city2"]

	state["at"] = {"package1": "location1", "package2": "location2"}
	state["truck_at"] = {"truck1": "location3", "truck6": "location10"}
	state["plane_at"] = {"plane2": "airport2"}

	state["in_city"] = {
		"airport1": "city1",
		"location1": "city1",
		"location2": "city1",
		"location3": "city1",
		"airport2": "city2",
		"location10": "city2"
	}
	planner.verbose = 0
	var task: Array = [["at", "package1", "location10"], ["at", "package2", "airport2"]]
	var plan: Variant = planner.find_plan(state, task)
	assert_eq_deep(plan, [["drive_truck", "truck1", "location1"], ["load_truck", "package1", "truck1"], ["drive_truck", "truck1", "airport1"], ["unload_truck", "package1", "airport1"], ["fly_plane", "plane2", "airport1"], ["load_plane", "package1", "plane2"], ["fly_plane", "plane2", "airport2"], ["unload_plane", "package1", "airport2"], ["drive_truck", "truck6", "airport2"], ["load_truck", "package1", "truck6"], ["drive_truck", "truck6", "location10"], ["unload_truck", "package1", "location10"], ["drive_truck", "truck1", "location2"], ["load_truck", "package2", "truck1"], ["drive_truck", "truck1", "airport1"], ["unload_truck", "package2", "airport1"], ["fly_plane", "plane2", "airport1"], ["load_plane", "package2", "plane2"], ["fly_plane", "plane2", "airport2"], ["unload_plane", "package2", "airport2"]])
