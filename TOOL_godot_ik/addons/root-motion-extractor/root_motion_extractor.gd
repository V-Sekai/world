@tool
extends Node

const root_motion_flags_const = preload("root_motion_flags.gd")
const root_motion_extractor_functions_const = preload("root_motion_extractor_functions.gd")

static func fill_missing_skeleton_tracks(source_file_path: String, p_scene: Node) -> Node:
	return root_motion_extractor_functions_const.fill_missing_skeleton_tracks(source_file_path, p_scene)

static func root_motion_import_function(p_file_path: String, p_scene: Node, p_root_motion_import_function: Dictionary) -> Node:
	return root_motion_extractor_functions_const.root_motion_import_function(p_file_path, p_scene, p_root_motion_import_function)

static func rename_animations_import_function(p_file_path: String, p_scene: Node, p_animation_map: Dictionary) -> Node:
	return root_motion_extractor_functions_const.rename_animations_import_function(p_file_path, p_scene, p_animation_map)

static func set_animations_loop_mode(p_file_path: String, p_scene: Node, p_loop_table: Dictionary) -> Node:
	return root_motion_extractor_functions_const.set_animations_loop_mode(p_file_path, p_scene, p_loop_table)
