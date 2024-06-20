extends Node

var http_request_post: HTTPRequest = HTTPRequest.new()
var http_request_get: HTTPRequest = HTTPRequest.new()
var http_request_download: HTTPRequest = HTTPRequest.new()

func _ready() -> void:
	print("_ready")
	var api_endpoint = "https://marcusloren-meshgpt.hf.space/call/predict"
	var data = {
		"data": ["chair", 1, 0]
	}
	var json_data = JSON.stringify(data)
	self.add_child(http_request_post)
	print("_ready::connect")
	http_request_post.connect("request_completed", _on_post_request_completed)
	print("_ready::request")
	var err: Error = http_request_post.request(api_endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_data)
	print(err)
	self.add_child(http_request_get)
	http_request_get.connect("request_completed", _on_get_request_completed)
	await http_request_post.request_completed

func _on_post_request_completed(_result, _response_code, _headers, body):
	print("_on_post_request_completed")
	var json_result = JSON.parse_string(body.get_string_from_utf8())
	print(json_result)
	if json_result.has("event_id"):
		var event_id = json_result.get("event_id")
		print("_on_post_request_completed::connect")
		print("_on_post_request_completed::request")
		var err: Error = http_request_get.request("https://marcusloren-meshgpt.hf.space/call/predict/" + str(event_id))
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
			if not element.has("url"):
				continue
			var download_url: String = element["url"]
			download_url = download_url.replace(".hf.space/c/file=", ".hf.space/file=")
			self.add_child(http_request_download)
			http_request_download.connect("request_completed", _on_download_request_completed)
			print(download_url)
			var err: Error = http_request_download.request(download_url)
			print(err)
			await http_request_download.request_completed

func _on_download_request_completed(result, response_code, _headers, body):
	print("_on_download_request_completed")
	print(result)
	if response_code == 200:
		print("Download successful!")
		var file = FileAccess.open("res://mesh.obj", FileAccess.WRITE)
		if file:
			file.store_buffer(body)
			file.close()
			print("File saved successfully!")
		else:
			print("Failed to open file.")
	else:
		print("Download failed with response code: ", response_code)
