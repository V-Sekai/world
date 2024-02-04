@tool
extends EditorPlugin

var skeleton_editor: VBoxContainer
var skeleton: Skeleton3D
var set_ik_range_from_button: Button
var selected_bone_name: String
var many_bone_ik: ManyBoneIK3D


func _enter_tree():
	set_ik_range_from_button = Button.new()
	set_ik_range_from_button.text = "Set IK Range From"
	var callable = Callable(self, "_on_set_ik_range_from_pressed")
	set_ik_range_from_button.pressed.connect(callable)
	if not set_ik_range_from_button.get_parent():
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, set_ik_range_from_button)
	connect_skeleton_tree_signal()

	
func _on_set_ik_range_from_pressed():
	print("_on_set_ik_range_from_pressed")
	if selected_bone_name.is_empty():
		return
	print(selected_bone_name)


func connect_skeleton_tree_signal():
	var editor_inspector = get_editor_interface().get_inspector()
	for childnode in editor_inspector.find_children("*", "Skeleton3DEditor", true, false):
		skeleton_editor = childnode as VBoxContainer
		for treenode in skeleton_editor.find_children("*", "Tree", true, false):
			var joint_tree := treenode as Tree
			if joint_tree != null:
				joint_tree.connect("item_selected", Callable(self, "joint_selected").bind(joint_tree))
				joint_tree.connect("nothing_selected", _on_nothing_selected)


func _on_nothing_selected():
	print("_on_nothing_selected")
		

func joint_selected(joint_tree: Tree):
	print("joint_selected")
	var selected_item = joint_tree.get_selected()
	if selected_item == null:
		_on_nothing_selected()
		return
	
	selected_bone_name = str(selected_item.get_text(0))
	var edited_object := get_editor_interface().get_inspector().get_edited_object()
	
	if edited_object != null and edited_object is Skeleton3D:
		skeleton = edited_object as Skeleton3D
	print(selected_bone_name)
	var nodes: Array[Node] = skeleton.find_children("*", "ManyBoneIK3D")
	if nodes.is_empty():
		return
	for elem: ManyBoneIK3D in nodes:
		many_bone_ik = elem
		var constraint_i = many_bone_ik.find_constraint(selected_bone_name)
		if constraint_i == -1:
			continue
		var twist_from_range = many_bone_ik.get_kusudama_twist(constraint_i)
		print(twist_from_range)
		return
