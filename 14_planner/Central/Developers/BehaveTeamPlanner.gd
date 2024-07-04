
extends Node

class_name BehaveTeamPlanner

## Define goals with conditions and priorities
var goals = {
    "keep_fire_burning": {"priority": 1, "condition": ["firepit_has_fuel", "firepit", false]},
    "keep_fed": {"priority": 1, "condition": ["hunger_level", "satyr", "low"]},
    "keep_fed_very_hungry": {"priority": 2, "condition": ["hunger_level", "satyr", "high"]},
    "calm_down": {"priority": 10, "condition": ["is_afraid", "satyr", true]},
    "relax": {"priority": 0, "condition": ["none", "satyr", null]}
}

## Assign a task based on the highest priority goal
func assign_task(memory: Dictionary) -> String:
    var task = "relax"
    var highest_priority = 0
    for goal in goals.keys():
        var (predicate, subject, object) = goals[goal]["condition"]
        if check_condition(predicate, subject, object, memory):
            if goals[goal]["priority"] > highest_priority:
                highest_priority = goals[goal]["priority"]
                task = goal
    return task

## Check if a condition is met for a given goal
func check_condition(predicate: String, subject: String, object: Variant, memory: Dictionary) -> bool:
    match predicate:
        "firepit_has_fuel":
            return memory.get([predicate, subject], false) == object
        "hunger_level":
            var hunger_level = memory.get(["hunger_level", subject], 0)
            return (object == "low" and hunger_level > 5 and hunger_level <= 10) or (object == "high" and hunger_level > 10)
        "is_afraid":
            return memory.get([predicate, subject], false) == object
        "none":
            return true
        _:
            return false