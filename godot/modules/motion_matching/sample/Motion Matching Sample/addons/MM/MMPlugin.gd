@uid("uid://dmisgwrk2os7b") # Generated automatically, do not modify.
@tool
extends EditorPlugin

var bottom_panel: Control

const MMEditorGizmoPlugin = preload("res://addons/MM/MMEditorGizmoPlugin.gd")
const MMPanel = preload("res://addons/MM/MMEditorPanel.tscn")

var gizmo_plugin: MMEditorGizmoPlugin


func _enter_tree() -> void:
	bottom_panel = MMPanel.instantiate()
	gizmo_plugin = MMEditorGizmoPlugin.new()
	add_node_3d_gizmo_plugin(gizmo_plugin)
	get_editor_interface().get_selection().selection_changed.connect(visibility)
	add_control_to_bottom_panel(bottom_panel, "Motion Matching")


func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_control_from_bottom_panel(bottom_panel)
	if(bottom_panel != null):
		bottom_panel.free()
	if gizmo_plugin != null:
		gizmo_plugin.free()


func _has_main_screen()->bool:
	return false


func visibility() -> void:
	var nodes :Array= get_editor_interface().get_selection().get_selected_nodes()
	var v = nodes.any(func(x):return x is MotionPlayer)
	bottom_panel.visible = v

	if v:
		print(get_tree())
		bottom_panel._current = nodes.filter(func (x): return x is MotionPlayer)[0] as MotionPlayer
		bottom_panel._animplayer = bottom_panel._current.owner.find_children("*","AnimationPlayer",true,true)[0]
		add_control_to_bottom_panel(bottom_panel,"MotionMatching")
		make_bottom_panel_item_visible(bottom_panel)
	else :
		remove_control_from_bottom_panel(bottom_panel)
