class_name LsgRibbonTrail3D
extends MeshInstance3D

var target_node: Node3D
var point_callable: Callable
var min_distance: float = 0.05
var max_points: int = 450
var trail_width: float = 0.22
var local_space: bool = true
var enabled_tracing: bool = true
var trail_color: Color = Color(0.44, 0.92, 1.0, 0.78)

var _points: Array[Vector3] = []


func _process(_delta: float) -> void:
	if not enabled_tracing:
		return
	_append_current_point()


func clear_trail() -> void:
	_points.clear()
	rebuild()


func set_target(node: Node3D) -> void:
	target_node = node


func set_point_callable(source: Callable) -> void:
	point_callable = source


func rebuild() -> void:
	if _points.size() < 2:
		mesh = null
		return

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(_points.size() - 1):
		var p0: Vector3 = _points[i]
		var p1: Vector3 = _points[i + 1]
		var tangent: Vector3 = (p1 - p0).normalized()
		if tangent.length() <= 0.0001:
			continue
		var side: Vector3 = tangent.cross(Vector3.UP)
		if side.length() <= 0.0001:
			side = tangent.cross(Vector3.RIGHT)
		side = side.normalized() * (trail_width * 0.5)

		var a: Vector3 = p0 - side
		var b: Vector3 = p0 + side
		var c: Vector3 = p1 + side
		var d: Vector3 = p1 - side

		st.set_color(trail_color)
		st.add_vertex(a)
		st.add_vertex(b)
		st.add_vertex(c)

		st.set_color(trail_color)
		st.add_vertex(a)
		st.add_vertex(c)
		st.add_vertex(d)

	st.generate_normals()
	mesh = st.commit()


func _append_current_point() -> void:
	var point: Variant = _sample_world_point()
	if point == null:
		return
	var sampled: Vector3 = point as Vector3
	if local_space:
		sampled = to_local(sampled)

	var should_append: bool = true
	if _points.size() > 0:
		should_append = _points[-1].distance_to(sampled) >= maxf(0.0, min_distance)
	if not should_append:
		return

	_points.append(sampled)
	if max_points > 0:
		while _points.size() > max_points:
			_points.remove_at(0)
	rebuild()


func _sample_world_point() -> Variant:
	if point_callable.is_valid():
		var v: Variant = point_callable.call()
		if v is Vector3:
			return v
	if target_node != null and is_instance_valid(target_node):
		return target_node.global_position
	return null
