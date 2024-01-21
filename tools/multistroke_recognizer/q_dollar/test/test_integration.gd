@uid("uid://di3aopewv1ylm") # Generated automatically, do not modify.
extends GutTest

const dollar = preload("res://q_dollar/core/q_dollar.gd")
var gestures = preload("res://q_dollar/core/gestures.gd").new()

var predefined_point_cloud: Dictionary = gestures.predefined_point_cloud

# Converts the captured points into a format suitable for the recognizer
func convert_points_for_recognition(gesture_points_strokes: Array) -> Array:
	var recognizer_points: Array[dollar.RecognizerPoint] = []
	for point in gesture_points_strokes:
		recognizer_points.append(dollar.RecognizerPoint.new(point.int_x, point.int_y, point.id))
	if recognizer_points.is_empty():
		print("Not enough points to resample for gesture recognition.")
		return []
	var point_cloud_id = str(Time.get_ticks_msec())
	var point_cloud = dollar.QDollarRecognizer.PointCloud.new(point_cloud_id, recognizer_points)
	return point_cloud._points
	
func test_assert_eq_integration_recognize_equal():
	var recognizer: dollar.QDollarRecognizer = dollar.QDollarRecognizer.new()
	
	assert_eq(dollar.QDollarRecognizer.PointCloud.NUMBER_POINTS, dollar.QDollarRecognizer.PointCloud.new("", 
		[dollar.RecognizerPoint.new(542, 548, 2),
		dollar.RecognizerPoint.new(544, 544, 2),
		dollar.RecognizerPoint.new(546, 540, 2),
		dollar.RecognizerPoint.new(546, 536, 2)])._points.size(), "Should be equal.")

	for gesture in predefined_point_cloud.keys():
		var points = predefined_point_cloud[gesture]
		@warning_ignore("unassigned_variable")
		var new_points: Array[dollar.RecognizerPoint]
		for point in points:
			new_points.push_back(point)
		recognizer.add_gesture(gesture, convert_points_for_recognition(new_points))

	for gesture_key in predefined_point_cloud.keys():
		var gestures = predefined_point_cloud[gesture_key]
		@warning_ignore("unassigned_variable")
		var new_points: Array[dollar.RecognizerPoint]
		new_points.resize(gestures.size())
		for point_i in range(gestures.size()):
			new_points[point_i] = gestures[point_i]
		var result: dollar.RecognizerResult = recognizer.recognize(new_points)
		assert_eq(gesture_key, result.name, "Test gesture %s: score: %f time: %f" %[result.name, result.score, result.time])

