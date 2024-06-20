@tool
extends EditorPlugin

var http_request_post: HTTPRequest = HTTPRequest.new()
var http_request_get: HTTPRequest = HTTPRequest.new()
var http_request_download: HTTPRequest = HTTPRequest.new()
const api_endpoint = "https://ifire-text-to-mesh-preview.hf.space/call/predict"
const const_obj_parse = preload("res://addons/obj_exporter/ObjParse.gd")

var button : Button
var line_edit : LineEdit

func _enter_tree() -> void:
	line_edit = LineEdit.new()
	line_edit.text = "hat"
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, line_edit)

	button = Button.new()
	button.text = "Generate Mesh"
	button.connect("pressed", _on_button_pressed)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, button)
	add_child(http_request_post)
	add_child(http_request_get)
	add_child(http_request_download)

func show_error_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()

func _on_button_pressed() -> void:
	print("_button_pressed")
	var editor_interface = get_editor_interface()
	var root = editor_interface.get_edited_scene_root()
	if root == null:
		show_error_dialog("No active scene. Please open a scene before generating mesh.")
		return
	var config = {
		"text": line_edit.text,
		"count": 1,
		"temperature": 0.0
	}
	send_request(config)

func send_request(config: Dictionary) -> void:
	var data = {
		"data": [config["text"], config["count"], config["temperature"]]
	}
	var json_data = JSON.stringify(data)
	print("_ready::connect")
	if not http_request_post.is_connected("request_completed", _on_post_request_completed):
		http_request_post.connect("request_completed", _on_post_request_completed)
	print("_ready::request")
	var err: Error = http_request_post.request(api_endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)
	print(err)
	if not http_request_get.is_connected("request_completed", _on_get_request_completed):
		http_request_get.connect("request_completed", _on_get_request_completed)
	await http_request_post.request_completed

func _on_post_request_completed(_result, _response_code, _headers, body):
	print("_on_post_request_completed")
	var body_string = body.get_string_from_utf8()
	print(body_string)
	var json_result = JSON.parse_string(body_string)
	print(json_result)
	if json_result.has("event_id"):
		var event_id = json_result.get("event_id")
		print("_on_post_request_completed::connect")
		print("_on_post_request_completed::request")
		var err: Error = http_request_get.request(api_endpoint + "/" + str(event_id))
		print(err)
		await http_request_get.request_completed

func _on_get_request_completed(result, _response_code, _headers, body):
	print("_on_get_request_completed")
	print(result)
	var string = body.get_string_from_utf8()
	print(string)
	var lines = string.split("\n")
	var key_value_pairs = {}
	for line in lines:
		if line != "":
			var parts = line.split(": ", false, 1)
			key_value_pairs[parts[0]] = parts[1]
	print(key_value_pairs)
	if key_value_pairs and key_value_pairs.has("data") and key_value_pairs["data"].length() > 0:
		var results = JSON.parse_string(key_value_pairs["data"])
		for element in results:
			if element == null:
				continue
			if not element.has("url"):
				continue
			var download_url: String = element["url"]
			download_url = download_url.replace(".hf.space/c/file=", ".hf.space/file=")
			if not http_request_download.is_connected("request_completed", _on_download_request_completed):
				http_request_download.connect("request_completed", _on_download_request_completed)
			print(download_url)
			var err: Error = http_request_download.request(download_url)
			print(err)
			await http_request_download.request_completed

func _on_download_request_completed(result, response_code, _headers, body: PackedByteArray):
	print("_on_download_request_completed")
	print(result)
	if response_code == 200:
		print("Download successful!")
		var obj_string = body.get_string_from_utf8()
		var mesh_resource: Mesh = const_obj_parse.load_obj_from_buffer(obj_string, Dictionary())
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = mesh_resource
		var material = StandardMaterial3D.new()
		material.cull_mode = StandardMaterial3D.CULL_DISABLED
		mesh_instance.material_override = material
		var root = EditorInterface.get_edited_scene_root()
		root.add_child(mesh_instance, true)
		mesh_instance.owner = root
	else:
		print("Download failed with response code: ", response_code)


func _exit_tree() -> void:
	http_request_post.queue_free()
	http_request_get.queue_free()
	http_request_download.queue_free()
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, button)
	button.queue_free()

	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, line_edit)
	line_edit.queue_free()
