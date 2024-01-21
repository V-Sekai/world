@uid("uid://dnfr5ang4x0r5") # Generated automatically, do not modify.
extends Node2D

# Member Variables
var gesture_points: Array = []
var current_path_2d: Path2D
var line_2d: Line2D
const LINE_WIDTH := 2
const LINE_COLOR := Color(0.4, 0.6, 0.8)
const LINE_RECOGNIZED_WIDTH := 4
const LINE_RECOGNIZED_COLOR := Color(0.928, 0.682, 0)
const q_dollar = preload("res://q_dollar/core/q_dollar.gd")
var gestures = preload("res://q_dollar/core/gestures.gd")
var recognizer: q_dollar.QDollarRecognizer
var debounce_timer: Timer
var strokes: Array = []
var label: Label

func _ready():
	recognizer = q_dollar.QDollarRecognizer.new()
	initialize_gestures()

	debounce_timer = Timer.new()
	debounce_timer.wait_time = 0.5
	debounce_timer.one_shot = true
	add_child(debounce_timer)
	debounce_timer.owner = self

	label = Label.new()
	label.name = "GestureLabel"
	add_child(label)
	label.owner = self
	
	debounce_timer.connect("timeout", Callable(self, "_on_debounce_timeout"))


## Initialize predefined gestures for recognition
func initialize_gestures():
	var recognized_gestures = gestures.new()
	for gesture in recognized_gestures.predefined_point_cloud.keys():
		var points = recognized_gestures.predefined_point_cloud[gesture]
		var new_points: Array[q_dollar.RecognizerPoint] = []
		for point in points:
			new_points.push_back(q_dollar.RecognizerPoint.new(point.x, point.y, str(Time.get_ticks_msec())))
		recognizer.add_gesture(gesture, new_points)


func start_new_stroke():
	gesture_points.clear()
	current_path_2d = Path2D.new()
	current_path_2d.curve = Curve2D.new()
	line_2d = Line2D.new()
	line_2d.width = LINE_WIDTH
	line_2d.default_color = LINE_COLOR
	add_child(line_2d)
	line_2d.owner = self

	add_child(current_path_2d)
	current_path_2d.owner = self
	label = Label.new()
	add_child(label)
	label.owner = self
	label.text = ""

## Ends the current stroke and prepares for possible recognition
func end_stroke():
	if current_path_2d and line_2d:
		update_gesture_path()
	strokes.append(current_path_2d)
	strokes.append(line_2d)
	strokes.append(label)
	current_path_2d = null
	line_2d = null
	label = null

## Captures user input for starting, updating, and ending strokes
func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if not current_path_2d:
			start_new_stroke()  # Start a new line at the beginning of a stroke
		gesture_points.append(Vector2(event.position.x, event.position.y))
		update_gesture_path()
		debounce_timer.start()
	elif event is InputEventScreenTouch and not event.pressed:
		end_stroke()  # End the current path when touch ends

## Updates the drawn path with the current gesture's points
func update_gesture_path() -> void:
	if current_path_2d and current_path_2d.curve:
		current_path_2d.curve.clear_points()
		for point in gesture_points:
			current_path_2d.curve.add_point(point)

	if line_2d:
		line_2d.points = PackedVector2Array(gesture_points)

## Triggers after a period of no interaction to attempt to recognize a gesture
func _on_debounce_timeout() -> void:
	if gesture_points.size() > 0:
		recognize_gesture()
	else:
		clear_paths()

## Converts the captured points into a format suitable for the recognizer
func convert_points_for_recognition(recognizer, gesture_points: Array) -> Array:
	if gesture_points.size() < 1:
		print("Not enough points to resample for gesture recognition.")
		return []
	var recognizer_points: Array[q_dollar.RecognizerPoint] = []
	for i in range(gesture_points.size()):
		var point = gesture_points[i]
		var timestamp = str(Time.get_ticks_msec())
		recognizer_points.append(q_dollar.RecognizerPoint.new(point.x, point.y, timestamp))

	var point_cloud_id = str(Time.get_ticks_msec())
	var point_cloud = q_dollar.QDollarRecognizer.PointCloud.new(point_cloud_id, recognizer_points)
	return point_cloud._points

## Displays the name of the recognized gesture on the screen
func display_recognized_gesture(result_name: String) -> void:
	for stroke in strokes:
		if stroke is Line2D:
			stroke.default_color = LINE_RECOGNIZED_COLOR
			stroke.width = LINE_RECOGNIZED_WIDTH
	var gesture_label = get_node("GestureLabel")
	gesture_label.text = result_name

## Processes the gesture points to attempt to recognize the gesture
func recognize_gesture() -> void:
	var points_for_recognition = convert_points_for_recognition(recognizer, gesture_points)
	if points_for_recognition.is_empty():
		return
	var result: q_dollar.RecognizerResult = recognizer.recognize(points_for_recognition)
	if not result.name.is_empty() and result.score > 0.3:
		print("Gesture recognized: %s with score: %f" % [result.name, result.score])
		display_recognized_gesture(result.name)
	else:
		print("No gesture recognized")
	debounce_timer.disconnect("timeout", Callable(self, "_on_debounce_timeout"))
	debounce_timer.connect("timeout", Callable(self, "clear_paths"), CONNECT_ONE_SHOT)
	debounce_timer.start(2.0)

## Clears all the paths after recognition or when no gesture is detected
func clear_paths():
	for stroke: Node in strokes:
		if not stroke or stroke.is_queued_for_deletion():
			continue
		stroke.queue_free()
	strokes.clear()
	debounce_timer.disconnect("timeout", Callable(self, "clear_paths"))
	debounce_timer.connect("timeout", Callable(self, "_on_debounce_timeout"))
	gesture_points.clear()
	if label:
		label.text = ""
