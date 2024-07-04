extends Plan

var keep_fire_burning: Multigoal = Multigoal.new()
var keep_fed: Multigoal = Multigoal.new()
var keep_fed_very_hungry: Multigoal = Multigoal.new()
var calm_down: Multigoal = Multigoal.new()
var relax: Multigoal = Multigoal.new()

## Initialize the goals and their states
func _init():
    keep_fire_burning.state["keep_fire_burning"].merge({"priority": 1})
    keep_fire_burning.state["firepit_has_fuel"].merge({"firepit": false})

    keep_fed.state["keep_fed"].merge({"priority": 1})
    keep_fed.state["hunger_level"].merge({"priority": 1})
    keep_fed.state["hunger_level"].merge({"satyr": "low"})

    keep_fed_very_hungry.state["keep_fed_very_hungry"].merge({"priority": 2})
    keep_fed_very_hungry.state["hunger_level"].merge({"satyr": "high"})

    calm_down.state["calm_down"].merge({"priority": 10})
    calm_down.state["is_afraid"].merge({"satyr": true})

    relax.state["relax"].merge({"priority": 0})

## Main behavior function that uses the new split functions
func behave(memory: Dictionary) -> Variant:
    return [["daemon_condition"], ["pick_goal"]]

## Function to pick the highest priority goal based on memory
func pick_goal(memory: Dictionary) -> Variant:
    var highest_priority = -1
    var selected_goal = ""
    var goals = {
        "keep_fire_burning": keep_fire_burning,
        "keep_fed": keep_fed,
        "keep_fed_very_hungry": keep_fed_very_hungry,
        "calm_down": calm_down,
        "relax": relax
    }
    for goal_name in goals.keys():
        var goal = goals[goal_name]
        for state_key in goal.state.keys():
            var condition = goal.state[state_key]
            for predicate in condition.keys():
                var subject = predicate
                var object = condition[predicate]
                if not memory.has(predicate) or not memory[predicate].has(subject):
                    continue
                var result = memory[predicate][subject] == object
                if not result:
                    continue
                if condition["priority"] > highest_priority:
                    highest_priority = condition["priority"]
                    selected_goal = goal_name
    return selected_goal

## Update memory with the perception and messages.
func update_condition(memory: Dictionary) -> Variant:
    var todo_list: Array[Array] = []
    for predicate in memory.keys():
        for subject in memory[predicate].keys():
            var object = memory[predicate][subject]
            match predicate:
                "firepit_has_fuel":
                    todo_list.append(["update_firepit_has_fuel", subject, object])
                "hunger_level":
                    todo_list.append(["check_hunger_level", subject, object])
                "is_afraid":
                    todo_list.append(["update_is_afraid", subject, object])
    return todo_list

## Check and update hunger level based on conditions
func check_hunger_level(memory: Dictionary, subject: String, object: Variant) -> void:
    var hunger_level = memory.get(["hunger_level", subject], 0)
    if (object == "low" and hunger_level > 5 and hunger_level <= 10):
        update_hunger_level_low(memory, subject, "low")
    elif (object == "high" and hunger_level > 10):
        update_hunger_level_high(memory, subject, "high")

## Update firepit fuel status in memory
func update_firepit_has_fuel(memory: Dictionary, subject: String, object: Variant) -> void:
    if memory.get(["firepit_has_fuel", subject], false) == object:
        memory["firepit_has_fuel"][subject] = true
        # Add additional logic to handle updating firepit fuel status

## Update hunger level to low in memory
func update_hunger_level_low(memory: Dictionary, subject: String, object: Variant) -> void:
    if memory.get(["hunger_level", subject], "") == object:
        memory["hunger_level"][subject] = "low"
        # Add additional logic to handle updating hunger level to low

## Update hunger level to high in memory
func update_hunger_level_high(memory: Dictionary, subject: String, object: Variant) -> void:
    if memory.get(["hunger_level", subject], "") == object:
        memory["hunger_level"][subject] = "high"
        # Add additional logic to handle updating hunger level to high

## Update fear status in memory
func update_is_afraid(memory: Dictionary, subject: String, object: Variant) -> void:
    if memory.get(["is_afraid", subject], false) == object:
        memory["is_afraid"][subject] = true
        # Add additional logic to handle updating fear status
