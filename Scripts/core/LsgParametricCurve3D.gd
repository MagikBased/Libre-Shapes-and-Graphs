class_name LsgParametricCurve3D
extends Node3D

var curve_name: StringName = &"helix"
var t_min: float = 0.0
var t_max: float = TAU * 3.0
var samples: int = 180
var curve_scale: float = 1.0
var center_offset: Vector3 = Vector3.ZERO
var phase: float = 0.0
var point_callable: Callable
var width: float = 0.08
var default_color: Color = Color(1.0, 0.72, 0.34)

var _points: Array[Vector3] = []
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_ensure_mesh_instance()
	rebuild()


func set_curve_callable(source: Callable) -> void:
	point_callable = source
	rebuild()


func clear_curve_callable() -> void:
	point_callable = Callable()
	rebuild()


func rebuild() -> void:
	clear_points()
	var count: int = maxi(2, samples)
	for i in range(count):
		var u: float = float(i) / float(maxi(1, count - 1))
		add_point(sample_at_ratio(u))
	_rebuild_mesh()


func sample_at_ratio(u: float) -> Vector3:
	var clamped_u: float = clampf(u, 0.0, 1.0)
	var t: float = lerpf(t_min, t_max, clamped_u)
	return evaluate_at(t)


func evaluate_at(t: float) -> Vector3:
	if point_callable.is_valid():
		var v: Variant = point_callable.call(t, phase)
		if v is Vector3:
			return (v as Vector3) * curve_scale + center_offset
	return _sample_builtin(t) * curve_scale + center_offset


func clear_points() -> void:
	_points.clear()


func add_point(p: Vector3) -> void:
	_points.append(p)


func get_point_count() -> int:
	return _points.size()


func get_point_position(index: int) -> Vector3:
	if index < 0 or index >= _points.size():
		return Vector3.ZERO
	return _points[index]


func _ensure_mesh_instance() -> void:
	if _mesh_instance != null:
		return
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)


func _rebuild_mesh() -> void:
	_ensure_mesh_instance()
	var immediate := ImmediateMesh.new()
	immediate.clear_surfaces()
	if _points.size() >= 2:
		immediate.surface_begin(Mesh.PRIMITIVE_LINES)
		immediate.surface_set_color(default_color)
		for i in range(_points.size() - 1):
			immediate.surface_add_vertex(_points[i])
			immediate.surface_add_vertex(_points[i + 1])
		immediate.surface_end()
	_mesh_instance.mesh = immediate


func _sample_builtin(t: float) -> Vector3:
	match String(curve_name).to_lower():
		"helix":
			return Vector3(cos(t), 0.22 * t, sin(t))
		"lissajous":
			return Vector3(sin(1.7 * t + phase), sin(2.3 * t), sin(3.1 * t + 0.5))
		"trefoil":
			return Vector3(
				sin(t) + 2.0 * sin(2.0 * t),
				cos(t) - 2.0 * cos(2.0 * t),
				-sin(3.0 * t + phase)
			) / 3.0
		"figure8":
			return Vector3(sin(t + phase), sin(2.0 * t), sin(3.0 * t + 0.8)) * 0.9
		_:
			return Vector3(cos(t), 0.22 * t, sin(t))
