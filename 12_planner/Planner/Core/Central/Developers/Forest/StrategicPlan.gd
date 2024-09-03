extends Plan

class_name StrategyPlan

signal goal_selected(goal)
signal goal_completed(result)

func _on_goal_completed(result):
	# Handle the result of the completed goal
	print("Goal completed with result: ", result)
