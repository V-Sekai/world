extends Camera3D
class_name FollowCam

@export var target_path: NodePath
@export var target_transform: Transform3D
@export var offset := Vector3(0.0, 0.5, 0.0)
@export var zoom: float = 2.75
@export_range(0.0, 1.0) var fp_responsiveness := 0.8
@export var fp_fov := 80.0
@onready var base_zoom := zoom
@onready var base_fov := fov
var _show_speed := false

var target_rotation: Basis
var target_position: Vector3
var target_origin: Vector3
var target_zoom := zoom

@onready var next_transform: Transform3D = global_transform
@onready var last_transform: Transform3D = global_transform

var exclusions: Array = []

func _update_exclusions():
	var tmp = exclusions.duplicate()
	for node in tmp:
		if not is_instance_valid(node):
			exclusions.erase(node)

func add_exclusion(node: Node, recursive := true):
	#print("excludey boy")
	if node is Node3D:
		if not exclusions.has(node):
			exclusions.append(node)
	if recursive:
		for child in node.get_children():
			add_exclusion(child, true)

func _update_target():
	var net_offset := offset + next_transform.basis * Vector3(0, 0.0, target_zoom)
	if target_transform != Transform3D.IDENTITY:
		target_origin = target_transform.origin + offset
		target_position = target_transform.origin + net_offset
		target_rotation = target_transform.basis.orthonormalized()
		return

	var target: Node3D = get_node_or_null(target_path)
	if not target:
		return

	target_origin = target.global_position + offset
	target_position = target.global_position + net_offset
	target_rotation = target.global_basis.orthonormalized()

func _physics_process(delta: float) -> void:
	_update_target()
	_update_exclusions()

	target_zoom = lerpf(target_zoom, zoom, 1.0 - exp(-5.0 * delta))
	var caffeine := lerpf(1.0, smoothstep(0.0, base_zoom, target_zoom), fp_responsiveness)
	fov = lerpf(fp_fov, base_fov, caffeine)
	var rot_laziness := 0.2
	var pos_laziness := 0.05
	var gp := next_transform.origin
	var gb := next_transform.basis
	if gp.distance_to(target_position) > target_zoom and target_zoom > 0.01:
		gp = target_position + target_position.direction_to(gp) * target_zoom
	var dss := get_world_3d().direct_space_state
	var ray_origin := target_origin
	var params := PhysicsShapeQueryParameters3D.new()
	params.transform = Transform3D(target_rotation, ray_origin)
	params.motion = gb.z * target_zoom
	var ball := SphereShape3D.new()
	ball.radius = near
	params.shape = ball
	params.collision_mask = 0x1 | 0x2 | 0x4
	params.exclude = exclusions
	var hit := dss.cast_motion(params)
	if hit:
		target_position = ray_origin + params.motion * maxf(0.0, hit[0] - ball.radius)
	gp = gp.lerp(target_position, 1.0 - exp(-(1.0 / (pos_laziness * caffeine)) * delta))
	gb = gb.slerp(target_rotation, 1.0 - exp(-(1.0 / (rot_laziness * caffeine)) * delta)).orthonormalized()
	last_transform = next_transform
	next_transform = Transform3D(gb, gp)

	if _show_speed:
		var speed := (next_transform.origin.distance_to(last_transform.origin) / delta) * 3.6
		DD.set_text("speed", "%d km/h" % speed)

func teleport():
	next_transform = global_transform
	last_transform = next_transform
	_update_target()

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_F3 and event.pressed:
			_show_speed = not _show_speed

func _process(_delta: float) -> void:
	var f := Engine.get_physics_interpolation_fraction()
	global_transform = last_transform.interpolate_with(next_transform, f).orthonormalized()
