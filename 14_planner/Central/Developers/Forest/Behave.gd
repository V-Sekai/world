extends Node

@onready var strategic_plan = preload("res://Central/Developers/Forest/StrategicPlan.gd").new()
@onready var tactical_plan = preload("res://Central/Developers/Forest/TacticalPlan.gd").new()
@onready var operational_plan = preload("res://Central/Developers/Forest/OperationalPlan.gd").new()

func _ready():
	# Connect signals between planners
	strategic_plan.connect("goal_selected", tactical_plan, "_on_goal_selected")
	tactical_plan.connect("task_selected", operational_plan, "_on_task_selected")

	# Example memory dictionary
	var memory = {
		"firepit_has_fuel": {"firepit": false},
		"hunger_level": {"satyr": "high"},
		"is_afraid": {"satyr": true}
	}

	# Offload the behavior process to worker threads
	var strategic_task_id = WorkerThreadPool.add_task(strategic_plan.behave, memory)
	WorkerThreadPool.wait_for_task_completion(strategic_task_id)

	var tactical_task_id = WorkerThreadPool.add_task(tactical_plan._on_goal_selected, tactical_plan.selected_goal)
	WorkerThreadPool.wait_for_task_completion(tactical_task_id)

	var operational_task_id = WorkerThreadPool.add_task(operational_plan._on_task_selected, operational_plan.selected_task)
	WorkerThreadPool.wait_for_task_completion(operational_task_id)
