@uid("uid://crdembknwgvwi") # Generated automatically, do not modify.
# Copyright (c) 2023-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors (see .all-contributorsrc).
# test_logistics.gd
# SPDX-License-Identifier: MIT

extends GutTest

#This file is based on the logistics-domain examples included with HGNpyhop:
#	https://github.com/ospur/hgn-pyhop
#For a discussion of the adaptations that were needed, see the relevant
#section of Some_GTPyhop_Details.md in the top-level directory.
#-- Dana Nau <nau@umd.edu>, July 20, 2021

var domain_name = "temporal_logistics"

var the_domain = preload("res://addons/task_goal/core/domain.gd").new(domain_name)

var planner = preload("res://addons/task_goal/core/plan.gd").new()


func handle_temporal_constraint(state, resource, current_time, goal_time, constraint_name) -> Variant:
	var constraint = TemporalConstraint.new(current_time, goal_time, goal_time - current_time, TemporalConstraint.TemporalQualifier.AT_END, constraint_name)
	if state["stn"][resource].check_overlap(constraint):
		if planner.verbose > 0:
			print("Error: Temporal constraint overlaped %s" % [str(constraint)])
		return false
	if state["stn"][resource].add_temporal_constraint(constraint):
		state["time"][resource] = goal_time
		return state
	else:
		if planner.verbose > 0:
			print("Error: Failed to add temporal constraint %s" % str(constraint))
	return false


## Actions


func drive_truck(state, t, l, time) -> Variant:
	if state.truck_at[t] == l:
		return state
	var constraint_name = "%s_drive_to_%s" % [t, l]
	var current_time = state["time"][t]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, t, current_time, time, constraint_name)
	if state and state["stn"][t].is_consistent():
		state.truck_at[t] = l
		state["time"][t] = time
		return state
	return false


func load_truck(state, o, t, time) -> Variant:
	if state.at[o] != state.truck_at[t]:
		# The package is not at the same location as the truck.
		return false
	var constraint_name = "%s_load_to_%s" % [o, t]
	var current_time = state["time"][o]
	if current_time > time:
		# The current time is already past the intended action time.
		return false
	state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
	if state and state["stn"][o].is_consistent():
		state.at[o] = t  # The package is now with the truck.
		state["time"][o] = time  # Update the time of the last action for this object.
		return state
	return false


func unload_truck(state, o, l, time) -> Variant:
	var t = state.at[o]
	if t == l or state.truck_at[t] != l:
		# The package is already at the location or the truck is not at the desired location.
		return false
	var constraint_name = "%s_unload_to_%s" % [o, l]
	var current_time = state["time"][o]
	if current_time > time:
		# The current time is already past the intended action time.
		return false
	state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
	if state and state["stn"][t].is_consistent():
		state.at[o] = l  # Unload the package to the location.
		state["time"][o] = time  # Update the time of the last action for this object.
		return state
	return false


func load_plane(state, o, plane, time) -> Variant:
	if state.at[o] == plane:
		return state
	var constraint_name = "%s_load_to_%s" % [o, plane]
	var current_time = state["time"][o]
	if current_time >= time:
		return false
	state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
	if state and state["stn"][o].is_consistent():
		state.at[o] = plane
		state["time"][plane] = time
		return state
	return false

func unload_plane(state, o, a, time) -> Variant:
	if state.at[o] == a:
		return state
	var plane = state.at[o]
	if state.plane_at[plane] == a:
		var constraint_name = "%s_unload_to_%s" % [o, a]
		var current_time = state["time"][o]
		if current_time >= time:
			return false
		state = handle_temporal_constraint(state, o, current_time, time, constraint_name)
		if state and state["stn"][o].is_consistent():
			state.at[o] = a
			state["time"][a] = time
			return state
	return false


func reschedule_task(state, resource, new_time) -> Variant:
	# First check if the resource can be rescheduled to the desired time.
	if state["stn"][resource].is_free_at(new_time):
		state["time"][resource] = new_time
		return state
	else:
		# If the resource is not free at the new_time, attempt to find an alternative schedule.
		var earliest_free_time = state["stn"][resource].find_earliest_free_time(new_time)
		if earliest_free_time != -1:
			state["time"][resource] = earliest_free_time
			return state
		else:
			if planner.verbose > 0:
				print("Error: Unable to reschedule %s to a new time." % [resource])
			return false
	

## Helper functions for the methods

# Find a truck in the same city as the package and available at the current time
func find_truck(state, o, time) -> Variant:
	for t in state.trucks:
		if state.in_city[state.truck_at[t]] == state.in_city[state.at[o]]:
			# Check if the truck is available using the is_free_at method.
			if state["stn"][t].is_free_at(time):
				return t
	return false


func find_plane(state, o, time) -> Variant:
	var fallback_plane = null
	for plane in state.airplanes:
		if state.in_city[state.plane_at[plane]] == state.in_city[state.at[o]]:
			if state["stn"][plane].is_free_at(time):
				return plane
			elif fallback_plane == null:
				fallback_plane = plane
	return fallback_plane if fallback_plane != null else false


# Find an airport in the same city as the location and available at the current time
func find_airport(state, l, time) -> Variant:
	for a in state.airports:
		if state.in_city[a] == state.in_city[l]:
			return a
	return false


## Methods to call the actions
func m_drive_truck(state, t, l):
	if t in state.trucks and l in state.locations and state.in_city[state.truck_at[t]] == state.in_city[l]:
		var current_time = state['time'][t]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, t, current_time)
		return [['drive_truck', t, l, new_time]]
	else:
		return false

func m_load_truck(state, o, t):
	if o in state.packages and t in state.trucks and state.at[o] != t and state.at[o] == state.truck_at[t]:
		var current_time = state['time'][t]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, t, current_time)
		return [['load_truck', o, t, new_time]]
	else:
		return false

func m_unload_truck(state, o, l):
	if o in state.packages and state.at[o] != l and state.at[o] in state.trucks and l in state.locations:
		var truck = state.at[o]
		var current_time = state['time'][truck]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, truck, current_time)
		return [['unload_truck', o, l, new_time]]
	else:
		return false

func m_fly_plane(state, plane, a):
	if plane in state.airplanes and a in state.airports:
		var current_time = state['time'][plane]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, plane, current_time)
		return [['fly_plane', plane, a, new_time]]
	else:
		return false

func m_load_plane(state, o, plane):
	if o in state.packages and plane in state.airplanes and state.at[o] != plane and state.at[o] == state.plane_at[plane]:
		var current_time = state['time'][plane]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, plane, current_time)
		return [['load_plane', o, plane, new_time]]
	else:
		return false

func m_unload_plane(state, o, a):
	if o in state.packages and state.at[o] != a and state.at[o] in state.airplanes and a in state.airports:
		var airplane = state.at[o]
		var current_time = state['time'][airplane]
		# Check if time slot is available or needs rescheduling
		var new_time = reschedule_if_needed(state, airplane, current_time)
		return [['unload_plane', o, a, new_time]]
	else:
		return false


func reschedule_if_needed(state, vehicle, current_time):
	if state["stn"][vehicle].is_free_at(current_time):
		return current_time
	else:
		var new_time = state["stn"][vehicle].find_earliest_free_time(current_time)
		if new_time != -1:
			if planner.verbose > 0:
				print("Rescheduled %s from time %d to %d." % [vehicle, current_time, new_time])
			return new_time
		else:
			if planner.verbose > 0:
				print("Error: Unable to reschedule %s; no available time slots." % vehicle)
			return false


func move_within_city(state, o, l) -> Variant:
	# Check if the object is a package, the target is a valid location,
	# and the movement is within the same city.
	if o in state.packages and l in state.locations and state.at[o] in state.locations \
	   and state.in_city[state.at[o]] == state.in_city[l]:
		var current_time = state.time[o]
		# Find a truck for transporting the package within the city based on its schedule.
		var truck = find_truck(state, o, current_time)

		# Ensure we get a valid truck.
		if truck: 
			# Attempt to reschedule the load operation if needed.
			var load_time = reschedule_if_needed(state, truck, current_time)
			if typeof(load_time) == TYPE_BOOL and load_time == false:
				return false

			# Assuming it takes 1 unit of time to load and drive.
			var drive_time = reschedule_if_needed(state, truck, load_time + 1)
			if typeof(drive_time) == TYPE_BOOL and drive_time == false:
				return false

			var unload_time = reschedule_if_needed(state, truck, drive_time + 1)
			if typeof(unload_time) == TYPE_BOOL and unload_time == false:
				return false

			# Return the sequence of tasks that need to be performed.
			return [
				["load_truck", o, truck, load_time],     # Load the package onto the truck.
				["drive_truck", truck, l, drive_time],   # Drive the truck to the new location.
				["unload_truck", o, l, unload_time]      # Unload the package at destination.
			]
	# If any conditions fail or operations cannot be scheduled, return false.
	return false


func move_between_city(state, o, l) -> Variant:
	if o in state.packages and l in state.locations and state.at[o] in state.locations and state.in_city[state.at[o]] != state.in_city[l]:
		var temp_time = state.time[o]
		var a1 = find_airport(state, state.at[o], temp_time)
		var a2 = find_airport(state, l, temp_time)
		if a1 and a2:
			var move_to_first_airport = ["move_within_city", o, a1]
			var move_to_second_airport = ["move_between_airports", o, a2]  # Note: You'll need to implement 'move_between_airports'.
			var move_within_dest_city = ["move_within_city", o, l]
			
			# Return nested calls as part of a compound task plan.
			# Note: You may want to consider delays/transit times between these steps as well.
			
			return [move_to_first_airport, move_to_second_airport, move_within_dest_city]
	return false



var state1: Dictionary


func before_each() -> void:
	state1.clear()
	
	# If we've changed to some other domain, this will change us back.
	planner.current_domain = the_domain
	planner.declare_actions([Callable(self, "drive_truck"), Callable(self, "load_truck"), Callable(self, "unload_truck"), Callable(self, "fly_plane"), Callable(self, "load_plane"), Callable(self, "unload_plane"), Callable(self, "reschedule_task")])

	planner.declare_unigoal_methods("at", [Callable(self, "m_load_truck"), Callable(self, "m_unload_truck"), Callable(self, "m_load_plane"), Callable(self, "m_unload_plane")])
	planner.declare_unigoal_methods("truck_at", [Callable(self, "m_drive_truck")])
	planner.declare_unigoal_methods("plane_at", [Callable(self, "m_fly_plane")])

	planner.declare_unigoal_methods("at", [Callable(self, "move_within_city"), Callable(self, "move_between_airports"), Callable(self, "move_between_city")])
	planner.declare_task_methods("move_within_city", [Callable(self, "move_within_city")])
	planner.declare_task_methods("move_between_airports", [Callable(self, "move_between_airports")])
	planner.declare_task_methods("move_within_city", [Callable(self, "move_between_city")])
#	planner.print_domain()

	state1.stn = {}
	state1.time = {}
	state1.packages = ["package1", "package2"]
	state1.trucks = ["truck1", "truck6"]
	state1.airplanes = ["plane2"]
	state1.locations = ["location1", "location2", "location3", "airport1", "location10", "airport2"]
	state1.airports = ["airport1", "airport2"]
	state1.cities = ["city1", "city2"]

	state1.at = {"package1": "location1", "package2": "location2"}
	state1.truck_at = {"truck1": "location3", "truck6": "location10"}
	state1.plane_at = {"plane2": "airport2"}
	state1.in_city = {"location1": "city1", "location2": "city1", "location3": "city1", "airport1": "city1", "location10": "city2", "airport2": "city2"}

	for c in state1.cities:
		state1["stn"][c] =  SimpleTemporalNetwork.new()
		state1.time[c] = 0
		
	for a in state1.airports:
		state1["stn"][a] =  SimpleTemporalNetwork.new()
		state1.time[a] = 0
		
	for p in state1.packages:
		state1["stn"][p] =  SimpleTemporalNetwork.new()
		state1.time[p] = 0

	for t in state1.trucks:
		state1["stn"][t] =  SimpleTemporalNetwork.new()
		state1.time[t] = 0

	for a in state1.airplanes:
		state1["stn"][a] =  SimpleTemporalNetwork.new()
		state1.time[a] = 0


func test_move_goal_1() -> void:
	planner.verbose = 1
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location2"], ["at", "package2", "location3"]])
	assert_eq(plan, [["drive_truck", "truck1", "location1", 2], ["load_truck", "package1", "truck1", 3], ["drive_truck", "truck1", "location2", 4], ["unload_truck", "package1", "location2", 5], ["load_truck", "package2", "truck1", 7], ["drive_truck", "truck1", "location3", 8], ["unload_truck", "package2", "location3", 9]])
	assert_eq(state2.time["truck1"], 9)
	assert_eq(state2.time["package1"], 5)
	assert_eq(state2.time["package2"], 9)


###	Goal 2: package1 is at location10 (transport to a different city)
func test_move_goal_2() -> void:
	planner.verbose = 3
	var plan = planner.find_plan(state1.duplicate(true), [["at", "package1", "location10"]])
	assert_eq(plan, [["drive_truck", "truck1", "location1"], ["load_truck", "package1", "truck1"], ["drive_truck", "truck1", "airport1"], ["unload_truck", "package1", "airport1"], ["fly_plane", "plane2", "airport1"], ["load_plane", "package1", "plane2"], ["fly_plane", "plane2", "airport2"], ["unload_plane", "package1", "airport2"], ["drive_truck", "truck6", "airport2"], ["load_truck", "package1", "truck6"], ["drive_truck", "truck6", "location10"], ["unload_truck", "package1", "location10"]])
	assert_eq(state1.time["truck1"], 3)
	assert_eq(state1.time["truck6"], 11)
	assert_eq(state1.time["plane2"], 7)
	assert_eq(state1.time["package1"], 12)


## Goal 3: package1 is at location1 (no actions needed)
func test_move_goal_3() -> void:
	planner.verbose = 0
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location1"]])
	assert_eq(plan, [])
	# No actions were performed, so the time should remain at 0
	assert_eq(state2.time["package1"], 0)


##	Goal 4: package1 is at location2
func test_move_goal_4() -> void:
	planner.verbose = 0
	var state2 = state1.duplicate(true)
	var plan = planner.find_plan(state2, [["at", "package1", "location2"]])
	assert_eq(plan, [["drive_truck", "truck1", "location1", 2], ["load_truck", "package1", "truck1", 3], ["drive_truck", "truck1", "location2", 4], ["unload_truck", "package1", "location2", 5]])
	assert_eq(state2.time["truck1"], 5)
	assert_eq(state2.time["package1"], 5)
