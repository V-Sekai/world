@uid("uid://di3aopewv1ylm") # Generated automatically, do not modify.
extends GutTest

const dollar = preload("res://q_dollar/core/q_dollar.gd")
var gestures = preload("res://q_dollar/core/gestures.gd").new()

var predefined_point_cloud: Dictionary = gestures.predefined_point_cloud

# Converts the captured points into a format suitable for the recognizer
func convert_points_for_recognition(gesture_points_strokes: Array) -> Array[dollar.RecognizerPoint]:
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
		[dollar.RecognizerPoint.new(542, 548, str(2)),
		dollar.RecognizerPoint.new(544, 544, str(2)),
		dollar.RecognizerPoint.new(546, 540, str(2)),
		dollar.RecognizerPoint.new(546, 536, str(2))])._points.size(), "Should be equal.")

	for gesture_key in predefined_point_cloud.keys():
		var gestures: Array[dollar.RecognizerPoint] = []
		for point in predefined_point_cloud[gesture_key]:
			gestures.append(point)
		recognizer.add_gesture(gesture_key, gestures)
		
	for gesture_key in predefined_point_cloud.keys():
		var gestures: Array[dollar.RecognizerPoint] = []
		for gesture in predefined_point_cloud[gesture_key]:
			gestures.append(gesture)
		var result: dollar.RecognizerResult = recognizer.recognize(gestures)
		assert_eq(gesture_key, result.name, "Test gesture %s: score: %f time: %f" %[result.name, result.score, result.time])

