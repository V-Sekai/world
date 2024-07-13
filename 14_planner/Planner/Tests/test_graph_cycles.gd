extends "res://addons/gut/test.gd"


func test_opposite_of_dag():
	var drag_drop_outfit = GraphGrammar.ProductionRule.new("ex:drag_drop_outfit", "gg:Rule", "setup_outfit_prefab", [{"node": "setup_animators", "edge": "next"}])
	var animator_setup = GraphGrammar.ProductionRule.new("ex:animator_setup", "gg:Rule", "setup_animators", [{"node": "after_setup", "edge": "next"}])
	var post_setup = GraphGrammar.ProductionRule.new("ex:post_setup", "gg:Rule", "after_setup", [{"node": "merge_bones", "edge": "next"}])
	var merge_bones = GraphGrammar.ProductionRule.new("ex:merge_bones", "gg:Rule", "merge_bones", [{"node": "setup_bone_proxies", "edge": "next"}])
	var setup_bone_proxies = GraphGrammar.ProductionRule.new("ex:setup_bone_proxies", "gg:Rule", "setup_bone_proxies", [{"node": "setup_cloth_colliders", "edge": "next"}])
	var setup_cloth_colliders = GraphGrammar.ProductionRule.new("ex:setup_cloth_colliders", "gg:Rule", "setup_cloth_colliders", [{"node": "setup_blendshape_sync", "edge": "next"}])
	var setup_blendshape_sync = GraphGrammar.ProductionRule.new("ex:setup_blendshape_sync", "gg:Rule", "setup_blendshape_sync", [{"node": "setup_outfit_prefab", "edge": "next"}]) # This creates a cycle

	var production_rules: Array[GraphGrammar.ProductionRule] = [
		drag_drop_outfit,
		animator_setup,
		post_setup,
		merge_bones,
		setup_bone_proxies,
		setup_cloth_colliders,
		setup_blendshape_sync
	]

	var possible_types = GraphGrammar.new(
		"ex:myGraphGrammar", 
		"gg:GraphGrammar", 
		["merge_bones", "setup_bone_proxies", "setup_cloth_colliders", "setup_blendshape_sync", "after_setup", "setup_animators", "setup_outfit_prefab"], 
		["setup_blendshape_sync"], 
		["next", "description"], 
		["next", "description"], 
		production_rules,
		"setup_outfit_prefab"
	)

	assert_true(!production_rules.is_empty())	

	var graph = {}
	for rule in production_rules:
		if !graph.has(rule.left_hand_side):
			graph[rule.left_hand_side] = []
		for rhs in rule.right_hand_side:
			if rhs["edge"] == "next":
				graph[rule.left_hand_side].append(rhs["node"])

	assert_true(GraphGrammar.has_cycle(graph))
