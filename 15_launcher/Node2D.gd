extends Control

@export_global_dir var godot_project

var pid = []

## URL to download
const DOWNLOAD_URL = "https://nightly.link/V-Sekai/world/workflows/build/main"

## Called when the node enters the scene tree for the first time.
func _ready():
    $VBoxContainer/Label.text = "Download Link: " + DOWNLOAD_URL
    $VBoxContainer/Button.text = "Download"
    $VBoxContainer/Button.connect("pressed", self, "_on_Button_pressed")
    $VBoxContainer/Button2.connect("pressed", self, "_on_Button2_pressed")
    $VBoxContainer/Off.connect("pressed", self, "_on_Off_pressed")

## Function to handle download button press
func _on_Button_pressed():
    var http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.connect("request_completed", self, "_on_request_completed")
    http_request.request(DOWNLOAD_URL)

## Callback function for request completion
func _on_request_completed(result, response_code, headers, body):
    if response_code == 200:
        print("Download successful!")
        var links = _parse_html(String(body))
        for link in links:
            print(link)
    else:
        print("Failed to download. Response code: ", response_code)

## Function to parse HTML and extract links
func _parse_html(html):
    var links = []
    var regex = RegEx.new()
    regex.compile(r'href="([^"]+\.zip)"')
    var result = regex.search_all(html)
    for match in result:
        links.append(match.get_string(1))
    return links

## Function to handle Button2 press
func _on_Button2_pressed():
    var args = ["--path", godot_project]
    pid = pid + [OS.create_instance(args)]

## Function to handle Off button press
func _on_Off_pressed():
    _stop_pid()

## Function to stop all processes in pid list
func _stop_pid():
    for p in pid:
        OS.kill(p)
        pid.erase(p)
