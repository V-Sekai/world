extends "res://addons/gut/test.gd"

func test_ready() -> void:
    var planner = Plan.new()
    planner.current_domain = Domain.new()
    
var state: Dictionary
    state["landmarks"] = ["package1", "package2"]
    state["at"] = {"player": "cafe"}
    planner.verbose = 0
    
    var gameplay_tasks: Array = [
        ["create_task", "game_storyline"],	
        ["assign_priority", "main_plot"],  
        ["design_landmarks", "central_district"],
        ["assign_importance", "key_locations"]  , 
        ["implement_quest_templates", "basic"],   
        ["create_task", "character_control"],	
        ["assign_priority", "player_interaction"],  
        ["polish_gameplay"],                    
        ["review_progress"],                     
        ["adjust_next_steps"]  ,             
        ["allocate_time", "unexpected_issues"]
    ]
    
    var out_of_gamelay_tasks: Array = [
        ["research_HTN_planning"],  
        ["sketch_main_menu"], 
        ["design_HUD"],                      
        ["implement_basic_functionality"],     
        ["profile_resource_usage"],            
        ["reduce_memory_leaks", "smooth_frame_rates"]   
    ]
    
    var task: Array = gameplay_tasks + out_of_gamelay_tasks
    
    var plan: Variant = planner.find_plan(state, task)
    assert_eq_deep(plan, [])
