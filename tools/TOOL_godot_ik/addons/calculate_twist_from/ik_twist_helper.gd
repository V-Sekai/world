@tool
extends EditorPlugin

var skeleton_editor: VBoxContainer

var skeleton: Skeleton3D
var selected_skel: Skeleton3D

func _enter_tree():
	var epsilon = 0.0001
	var set_ik_range_from_button: Button = Button.new()
	set_ik_range_from_button.text = "Set IK Range From"
	set_ik_range_from_button.pressed.connect(_on_set_ik_range_from_pressed, epsilon)
	add_child(set_ik_range_from_button)
	connect_skeleton_tree_signal()

func connect_skeleton_tree_signal():
	var editor_inspector = get_editor_interface().get_inspector()
	var skeleton_editor: VBoxContainer = null
	for childnode in editor_inspector.find_children("*", "Skeleton3DEditor", true, false):
		skeleton_editor = childnode as VBoxContainer
		for treenode in skeleton_editor.find_children("*", "Tree", true, false):
			var joint_tree := treenode as Tree
			if joint_tree != null:
				joint_tree.connect("item_selected", joint_selected.bind(joint_tree))


func _on_set_ik_range_from_pressed(epsilon):
	pass

func joint_selected(joint_tree: Tree):
	var selected_bone_name = str(joint_tree.get_selected().get_text(0))
	var edited_object := get_editor_interface().get_inspector().get_edited_object()
	if edited_object != null and edited_object is Skeleton3D and edited_object != selected_skel:
		skeleton = edited_object as Skeleton3D
	print(selected_bone_name)
		
