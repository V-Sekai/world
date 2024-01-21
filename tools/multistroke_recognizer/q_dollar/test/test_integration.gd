@uid("uid://di3aopewv1ylm") # Generated automatically, do not modify.
extends GutTest

const dollar = preload("res://q_dollar/core/q_dollar.gd")
var gestures = preload("res://q_dollar/core/gestures.gd").new()

var predefined_point_cloud = gestures.predefined_point_cloud

var recognizer = null

func before_each():
	recognizer = dollar.QDollarRecognizer.new()
	
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
	
	
func test_resample():
	var gesture_points: Array[dollar.RecognizerPoint] = [dollar.RecognizerPoint.new(0, 0, str(0)), dollar.RecognizerPoint.new(1, 1, str(1))]
	var point_cloud = dollar.QDollarRecognizer.PointCloud.new("test", gesture_points)
	point_cloud._points = gesture_points
	point_cloud._points = point_cloud.resample(point_cloud._points, dollar.QDollarRecognizer.PointCloud.NUMBER_POINTS)
	assert_eq(point_cloud._points.size(), dollar.QDollarRecognizer.PointCloud.NUMBER_POINTS, "Resample method does not produce correct number of points")


func test_scale():
	var gesture_points: Array[dollar.RecognizerPoint] = [dollar.RecognizerPoint.new(0, 0, str(0)), dollar.RecognizerPoint.new(2, 2, str(2))]
	var point_cloud = dollar.QDollarRecognizer.PointCloud.new("test", gesture_points)
	point_cloud._points = gesture_points
	point_cloud._points = point_cloud.scale(gesture_points)
	var max_x = -INF
	var max_y = -INF
	for point in point_cloud._points:
		if point.x > max_x:
			max_x = point.x
		if point.y > max_y:
			max_y = point.y
	assert_eq(max_x, 1.0, "Scale method does not correctly scale x coordinates")
	assert_eq(max_y, 1.0, "Scale method does not correctly scale y coordinates")


func test_translate_to():
	var gesture_points: Array[dollar.RecognizerPoint] = [dollar.RecognizerPoint.new(1, 1, str(0)), dollar.RecognizerPoint.new(2, 2, str(2))]
	var point_cloud = dollar.QDollarRecognizer.PointCloud.new("test", gesture_points)
	point_cloud._points = gesture_points
	point_cloud._points = point_cloud.translate_to(point_cloud._points, dollar.RecognizerPoint.new(0, 0, str(0)))
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	for point in point_cloud._points:
		if point.x < min_x:
			min_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.x > max_x:
			max_x = point.x
		if point.y > max_y:
			max_y = point.y
	assert_eq((min_x + max_x) / 2, 0.0, "Translate_to method does not correctly translate x coordinates")
	assert_eq((min_y + max_y) / 2, 0.0, "Translate_to method does not correctly translate y coordinates")


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
		var points: Array[dollar.RecognizerPoint]
		for p in predefined_point_cloud[gesture_key]:
			points.push_back(p)
		var result: dollar.RecognizerResult = recognizer.recognize(points)
		assert_eq(result.name, gesture_key, "Gesture %s doesn't match result %s: score: %f time: %f" %[gesture_key, result.name, result.score, result.time])


func test_recognizer():
	var recognizer = dollar.QDollarRecognizer.new()
	
	# Define some mock points for a gesture 'triangle'
	var triangle_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(1, 1, "0"),
		dollar.RecognizerPoint.new(2, 0, "0"),
		dollar.RecognizerPoint.new(0, 0, "0")
	]
	
	# Add the triangle gesture to the recognizer
	recognizer.add_gesture("triangle", triangle_points)
	
	# Now we create a candidate set of points that should resemble a triangle
	var candidate_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(1.1, 1.1, "0"), 
		dollar.RecognizerPoint.new(2, 0, "0"),
		dollar.RecognizerPoint.new(0, -0.1, "0")
	]
	
	# Recognize the gesture
	var result = recognizer.recognize(candidate_points)
	assert_eq(result.name, "triangle", "The recognized gesture should be a triangle.")
	assert_true(result.score > 0.8, "The score should be higher than 0.8 for a good match.")
	assert_true(result.time >= 0, "Time should not be negative.")
	
	# Delete user gestures added to the recognizer for cleanup
	recognizer.delete_user_gestures()

func test_multiple_recognizer():
	var recognizer = dollar.QDollarRecognizer.new()
	
	# Define some mock points for a gesture 'triangle'
	var triangle_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(1, 1, "0"),
		dollar.RecognizerPoint.new(2, 0, "0"),
		dollar.RecognizerPoint.new(0, 0, "0")
	]
	
	# Define some mock points for a gesture 'square'
	var square_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(0, 1, "0"),
		dollar.RecognizerPoint.new(1, 1, "0"),
		dollar.RecognizerPoint.new(1, 0, "0"),
		dollar.RecognizerPoint.new(0, 0, "0")
	]
	
	# Add the gestures to the recognizer
	recognizer.add_gesture("triangle", triangle_points)
	recognizer.add_gesture("square", square_points)
	
	# Now we create a candidate set of points that should resemble a triangle
	var triangle_candidate_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(1.1, 1.1, "0"), 
		dollar.RecognizerPoint.new(2, 0, "0"),
		dollar.RecognizerPoint.new(0, -0.1, "0")
	]
	
	# Recognize the triangle gesture
	var triangle_result = recognizer.recognize(triangle_candidate_points)
	assert_eq(triangle_result.name, "triangle", "The recognized gesture should be a triangle.")
	assert_true(triangle_result.score > 0.8, "The score should be higher than 0.8 for a good match with a triangle.")
	assert_true(triangle_result.time >= 0, "Time should not be negative for a triangle recognition.")
	
	# Now we create a candidate set of points that should resemble a square
	var square_candidate_points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0.1, 0.1, "0"),
		dollar.RecognizerPoint.new(0.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 0.1, "0"),
		dollar.RecognizerPoint.new(0.1, 0.1, "0")
	]
	
	# Recognize the square gesture
	var square_result = recognizer.recognize(square_candidate_points)
	assert_eq(square_result.name, "square", "The recognized gesture should be a square.")
	assert_true(square_result.score > 0.8, "The score should be higher than 0.8 for a good match with a square.")
	assert_true(square_result.time >= 0, "Time should not be negative for a square recognition.")
	
	# Delete user gestures added to the recognizer for cleanup
	recognizer.delete_user_gestures()

func test_cloud_distance():
	var minimum_so_far = INF
	
	# Define some mock points for comparison
	var cloud1: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(0, 1, "0"),
		dollar.RecognizerPoint.new(1, 1, "0"),
		dollar.RecognizerPoint.new(1, 0, "0")
	]
	
	var cloud2: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0.1, 0.1, "0"),
		dollar.RecognizerPoint.new(0.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 0.1, "0")
	]
	var recognizer = dollar.QDollarRecognizer.new()
	# Calculate cloud distance from cloud1 to cloud2 starting with the first point
	var distance = recognizer._cloud_distance(cloud1, cloud2, 0, minimum_so_far)
	
	# Ensure that the distance is within an acceptable range
	# This assert check depends on the expected behavior of your '_cloud_distance' implementation and can be adjusted accordingly
	assert_lt(distance, minimum_so_far, "The cloud distance should be less than the initial minimum set.")
	
	
func test_cloud_match():
	var minimum_so_far = 10.0 

	var cloud1 = dollar.QDollarRecognizer.PointCloud.new("cloud1", [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(0, 1, "0"),
		dollar.RecognizerPoint.new(1, 1, "0"),
		dollar.RecognizerPoint.new(1, 0, "0")
	])
	
	var cloud2 = dollar.QDollarRecognizer.PointCloud.new("cloud2", [
		dollar.RecognizerPoint.new(0.1, 0.1, "0"),
		dollar.RecognizerPoint.new(0.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 1.1, "0"),
		dollar.RecognizerPoint.new(1.1, 0.1, "0")
	])
	
	# Calculate match distance between the two cloud points
	var match_distance = recognizer._cloud_match(cloud1, cloud2, minimum_so_far)
	
	# Assert that the match distance is less than the minimum set (if applicable)
	assert_true(match_distance < minimum_so_far, "The match distance should be less than the initial minimum.")
	
	
func test_point_cloud_resample_returns_n_points():
	var points: Array[dollar.RecognizerPoint] = [
		dollar.RecognizerPoint.new(0, 0, "0"),
		dollar.RecognizerPoint.new(0, 50, "0"),
		dollar.RecognizerPoint.new(50, 50, "0"),
		dollar.RecognizerPoint.new(50, 0, "0")
	]
	var resampled_points: Array[dollar.RecognizerPoint] = recognizer.PointCloud.new("point_cloud", points)._points
	assert_eq(resampled_points.size(), dollar.QDollarRecognizer.PointCloud.NUMBER_POINTS, "Resampled points should have 'n' points")


func test_point_cloud_translate_moves_origin():
	var points: Array[dollar.RecognizerPoint] = [dollar.RecognizerPoint.new(1, 1, "0"), dollar.RecognizerPoint.new(2, 2, "0")]
	var new_origin: dollar.RecognizerPoint = dollar.RecognizerPoint.new(0, 0, "0")
	var new_point_cloud:  dollar.QDollarRecognizer.PointCloud = recognizer.PointCloud.new("point_cloud", points)
	var translated_points = new_point_cloud.translate_to(points, new_origin)
	var expected: Array[dollar.RecognizerPoint]= [dollar.RecognizerPoint.new(-0.5, -0.5, "0"), dollar.RecognizerPoint.new(0.5, 0.5, "0")]
	for i in range(translated_points.size()):
		assert_almost_eq(translated_points[i].x, expected[i].x, 0.01)
		assert_almost_eq(translated_points[i].y, expected[i].y, 0.01)
