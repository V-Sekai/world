class_name MeshGeometricProcessor

var triangle_vocabulary: Dictionary = {}
var reverse_vocabulary: Dictionary = {}

class resnet:
	func predict(_features: Array):
		var result = 0
		for feature in _features:
			result += feature # or any other operation you want to perform
		return result

var resnet_model = resnet.new()

func compare_vertices(vertex_a, vertex_b):
	if vertex_a.z < vertex_b.z:
		return -1
	elif vertex_a.z > vertex_b.z:
		return 1
	elif vertex_a.y < vertex_b.y:
		return -1
	elif vertex_a.y > vertex_b.y:
		return 1
	elif vertex_a.x < vertex_b.x:
		return -1
	elif vertex_a.x > vertex_b.x:
		return 1

	return 0

func compare_faces(face_a, face_b):
	for i in range(3):
		var vertex_comparison = compare_vertices(face_a["vertices"][i], face_b["vertices"][i])
		if vertex_comparison != 0:
			return vertex_comparison

	if "id" in face_a and "id" in face_b:
		if face_a["id"] < face_b["id"]:
			return -1
		elif face_a["id"] > face_b["id"]:
			return 1

	return 0

func _init(mesh: ArrayMesh) -> void:
	var mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(mesh, 0)

	var triangles: Array = []

	for i in range(0, mesh_data_tool.get_vertex_count(), 3):
		var triangle = {
			"vertices": [],
			"normals": [],
			"tangents": [],
			"uvs": [],
			"face_area": 0,
			"angle": 0,
			"tangent": Vector3.ZERO,
			"id": i
		}

		for j in range(3):
			var index = i + j
			triangle["vertices"].append(mesh_data_tool.get_vertex(index))
			triangle["normals"].append(mesh_data_tool.get_vertex_normal(index))
			triangle["tangents"].append(mesh_data_tool.get_vertex_tangent(index))
			triangle["uvs"].append(mesh_data_tool.get_vertex_uv(index))

		triangle["face_area"] = calculate_face_area(triangle["vertices"])
		triangle["angle"] = calculate_angle(triangle["vertices"])
		triangle["tangent"] = calculate_tangent(triangle["vertices"])

		triangles.append(triangle)

	triangles.sort_custom(Callable(self, "compare_faces"))

	build_vocabulary(triangles)
	build_reverse_vocabulary()

func calculate_face_area(vertices: Array) -> float:
	var v0 = vertices[0]
	var v1 = vertices[1]
	var v2 = vertices[2]
	return ((v1 - v0).cross(v2 - v0)).length() / 2.0

func calculate_angle(vertices: Array) -> float:
	var v0 = vertices[0] - vertices[1]
	var v1 = vertices[2] - vertices[1]
	return v0.angle_to(v1)

func calculate_tangent(vertices: Array) -> Vector3:
	var v0 = vertices[0]
	var v1 = vertices[1]
	var v2 = vertices[2]
	var edge1 = v1 - v0
	var edge2 = v2 - v0
	return edge1.cross(edge2).normalized()

func encode(triangle: Dictionary) -> int:
	if triangle in triangle_vocabulary:
		return triangle_vocabulary[triangle]
	else:
		print("Triangle not found in vocabulary.")
		return -1

func decode(vocab: int) -> Dictionary:
	if vocab in reverse_vocabulary:
		return reverse_vocabulary[vocab]
	else:
		print("Encoded value not found in reverse vocabulary.")
		return {}

func build_vocabulary(triangles: Array) -> void:
	var aggregated_features: Dictionary = aggregate_vertex_features(triangles)
	var quantized_positions: Dictionary = quantize_vertex_positions(aggregated_features)
	for triangle: Dictionary in triangles:
		var vertex_features: Array = extract_vertex_features(triangle)
		for i: int in range(vertex_features.size()):
			vertex_features[i] = quantized_positions[vertex_features[i]]
		var graph_conv_features: Array = graph_conv(vertex_features)
		var encoded: String = residual_quantization_16384_plane15(graph_conv_features)
		triangle_vocabulary[triangle] = encoded

func build_reverse_vocabulary() -> void:
	for key: Dictionary in triangle_vocabulary.keys():
		reverse_vocabulary[triangle_vocabulary[key]] = key

func extract_vertex_features(_triangle: Dictionary) -> Array:
	var vertex_features: Array = []
	for vertex: Dictionary in _triangle.values():
		for feature: Array in vertex.values():
			vertex_features.append(feature)
	return vertex_features

func graph_conv(_features: Array) -> Array:
	return []


## This function uses Plane 15 for encoding.
## Triangle Face 1: U+F0001 
##
## Parameters:
## _features (Array): The input features for the model.
##
## Returns:
## String: The encoded unicode code output from the model.
func residual_quantization_16384_plane15(_features) -> String:
	var encoded = resnet_model.predict(_features)
	return encoded

func get_encoded_vocabulary() -> Dictionary:
	return triangle_vocabulary

func get_decoded_vocabulary() -> Dictionary:
	return reverse_vocabulary

func update_triangle_vocabulary(triangle: Dictionary, encoded: int) -> void:
	triangle_vocabulary[triangle] = encoded

func remove_from_triangle_vocabulary(triangle: Dictionary) -> void:
	triangle_vocabulary.erase(triangle)

func update_reverse_vocabulary(encoded: int, triangle: Dictionary) -> void:
	reverse_vocabulary[encoded] = triangle

func remove_from_reverse_vocabulary(encoded: int) -> void:
	reverse_vocabulary.erase(encoded)

func aggregate_vertex_features(triangles: Array) -> Dictionary:
	var aggregated_features: Dictionary = {}
	for triangle: Dictionary in triangles:
		var vertex_features: Array = extract_vertex_features(triangle)
		for vertex_index: int in triangle.keys():
			if vertex_index in aggregated_features:
				aggregated_features[vertex_index].append(vertex_features[vertex_index])
			else:
				aggregated_features[vertex_index] = [vertex_features[vertex_index]]
	return aggregated_features

func quantize_vertex_positions(aggregated_features: Dictionary) -> Dictionary:
	var quantized_positions: Dictionary = {}
	for vertex_index: int in aggregated_features.keys():
		var position: Array = aggregated_features[vertex_index]
		var quantized_position: Array = [round(position[0] * 128), round(position[1] * 128), round(position[2] * 128)]
		quantized_positions[vertex_index] = quantized_position
	return quantized_positions
