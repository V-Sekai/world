@uid("uid://dnfr5ang4x0r5") # Generated automatically, do not modify.
extends Node2D

var gesture_points: Array[Array] = []
var line_2d: Line2D
const LINE_WIDTH := 2
const LINE_COLOR := Color(0.4, 0.6, 0.8)
const LINE_RECOGNIZED_WIDTH := 4
const LINE_RECOGNIZED_COLOR := Color(0.928, 0.682, 0.0)
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
	debounce_timer.wait_time = 0.8
	debounce_timer.one_shot = true
	add_child(debounce_timer)
	debounce_timer.owner = self
	
	label = Label.new()
	label.name = "GestureLabel"
	add_child(label)
	label.owner = self

	debounce_timer.connect("timeout", Callable(self, "_on_debounce_timeout"))
	

# Initialize predefined gestures for recognition
func initialize_gestures():
	var recognized_gestures = gestures.new()
	for gesture in recognized_gestures.predefined_point_cloud.keys():
		var points = recognized_gestures.predefined_point_cloud[gesture]
		var new_points: Array[q_dollar.RecognizerPoint] = []
		for point in points:
			new_points.push_back(q_dollar.RecognizerPoint.new(point.x, point.y, str(point.id)))
		recognizer.add_gesture(gesture, new_points)

func start_new_stroke():
	line_2d = Line2D.new()
	line_2d.width = LINE_WIDTH
	line_2d.default_color = LINE_COLOR
	add_child(line_2d)
	line_2d.owner = self
	current_stroke.clear()


# Ends the current stroke and prepares for possible recognition
func end_stroke():
	var stroke_data: Dictionary = {
			"line": line_2d,
			"label": label,
			"stroke_id": gesture_points.size() + 1
		}
	strokes.append(stroke_data) # Append the dictionary created for the current stroke
	line_2d = null
	label = null


var current_stroke: Array[Vector2] = []

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		start_new_stroke()
	elif event is InputEventScreenDrag:
		update_gesture_path()
		current_stroke.append(event.position)
	elif event is InputEventScreenTouch and not event.pressed:
		gesture_points.append(current_stroke.duplicate())
		end_stroke()
		debounce_timer.start()


# Updates the drawn path with the current gesture's points
func update_gesture_path() -> void:
	if line_2d:
		var points: PackedVector2Array = []
		for point in current_stroke:
			points.push_back(point)
		line_2d.points = points

# Triggers after a period of no interaction to attempt to recognize a gesture
func _on_debounce_timeout() -> void:
	recognize_gesture()

# Converts the captured points into a format suitable for the recognizer
func convert_points_for_recognition(recognizer, gesture_points_strokes: Array[Array]) -> Array:
	var recognizer_points: Array[q_dollar.RecognizerPoint] = []
	for stroke_i in range(gesture_points_strokes.size()):
		for point in gesture_points_strokes[stroke_i]:
			recognizer_points.append(q_dollar.RecognizerPoint.new(point.x, point.y, str(stroke_i)))

	if recognizer_points.is_empty():
		print("Not enough points to resample for gesture recognition.")
		return []
	var point_cloud_id = str(Time.get_ticks_msec())
	var point_cloud: q_dollar.QDollarRecognizer.PointCloud = q_dollar.QDollarRecognizer.PointCloud.new(point_cloud_id, recognizer_points)
	return point_cloud._points

# Displays the name of the recognized gesture on the screen
func display_recognized_gesture(result_name: String) -> void:
	for stroke_dict in strokes:
		if stroke_dict["line"] is Line2D:
			stroke_dict["line"].default_color = LINE_RECOGNIZED_COLOR
			stroke_dict["line"].width = LINE_RECOGNIZED_WIDTH
		if stroke_dict["label"] is Label:
			stroke_dict["label"].text = "Stroke %d: %s" % [stroke_dict["stroke_id"], result_name]

# Processes the gesture points to attempt to recognize the gesture
func recognize_gesture() -> void:
	var points_for_recognition: Array = convert_points_for_recognition(recognizer, gesture_points)
	if not (points_for_recognition.size() != recognizer.PointCloud.NUMBER_POINTS):
		var result: q_dollar.RecognizerResult = recognizer.recognize(points_for_recognition)
		if not result.name.is_empty() and result.name != "No match." and result.score > .6:
			print("Gesture recognized: %s with score: %f" % [result.name, result.score])
			display_recognized_gesture(result.name)
		else:
			var output = "\"No match:\":\t\t[\n"
			for point in points_for_recognition:
				output += "\t\t\tq_dollar.RecognizerPoint.new(%d, %d, \"%s\"),\n" % [point.int_x, point.int_y, point.id]
			output += "\t\t],"
			print(output)

	if debounce_timer.has_signal("timeout"):
		debounce_timer.disconnect("timeout", Callable(self, "_on_debounce_timeout"))
	debounce_timer.connect("timeout", Callable(self, "clear_paths"), CONNECT_ONE_SHOT)
	debounce_timer.start(2.0)

# Clears all the paths after recognition or when no gesture is detected
func clear_paths():
	for stroke_dict in strokes:
		if stroke_dict["line"]:
			stroke_dict["line"].queue_free()
		if stroke_dict["label"]:
			stroke_dict["label"].queue_free()
	strokes.clear()
	if debounce_timer.has_signal("timeout"):
		debounce_timer.disconnect("timeout", Callable(self, "clear_paths"))
	debounce_timer.connect("timeout", Callable(self, "_on_debounce_timeout"))
	gesture_points.clear()
	if label:
		label.text = ""
