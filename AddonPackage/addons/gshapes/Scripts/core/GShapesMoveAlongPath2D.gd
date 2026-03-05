class_name GShapesMoveAlongPath2D
extends GShapesAnimation

var path_points: PackedVector2Array = PackedVector2Array()
var closed_path: bool = false
var orient_to_path: bool = false
var path_owner: Node2D
var orientation_angle_offset: float = 0.0
var tangent_epsilon: float = 0.003


func _init(
	p_target: Node2D,
	p_path_points: PackedVector2Array,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_closed_path: bool = false,
	p_orient_to_path: bool = false,
	p_path_owner: Node2D = null
) -> void:
	path_points = p_path_points
	closed_path = p_closed_path
	orient_to_path = p_orient_to_path
	path_owner = p_path_owner
	super(p_target, p_run_time, p_rate_func_name)


func set_path_points(points: PackedVector2Array, closed: bool = false, owner: Node2D = null) -> void:
	path_points = points
	closed_path = closed
	path_owner = owner


func interpolate(alpha: float) -> void:
	if target == null:
		return
	if path_points.size() < 2:
		return

	var a: float = clampf(alpha, 0.0, 1.0)
	var sampled_local: Vector2 = GShapesPathUtils.sample_polyline(path_points, a, closed_path)
	target.global_position = _to_world(sampled_local)

	if orient_to_path:
		var next_alpha: float = clampf(a + tangent_epsilon, 0.0, 1.0)
		var p0: Vector2 = _to_world(sampled_local)
		var p1: Vector2 = _to_world(GShapesPathUtils.sample_polyline(path_points, next_alpha, closed_path))
		var tangent: Vector2 = p1 - p0
		if tangent.length_squared() > 0.000001:
			target.global_rotation = tangent.angle() + orientation_angle_offset


func _to_world(local_point: Vector2) -> Vector2:
	if path_owner != null and is_instance_valid(path_owner):
		return path_owner.to_global(local_point)
	return local_point




