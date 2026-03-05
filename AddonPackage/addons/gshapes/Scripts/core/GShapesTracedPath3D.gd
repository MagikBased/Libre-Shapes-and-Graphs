class_name GShapesTracedPath3D
extends Node3D

var target_node: Node3D
var point_callable: Callable
var min_distance: float = 0.05
var max_points: int = 0
var local_space: bool = true
var enabled_tracing: bool = true
var width: float = 0.05
var default_color: Color = Color(0.42, 0.95, 1.0)

var _points: Array[Vector3] = []
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_ensure_mesh_instance()
	_rebuild_mesh()


func _process(_delta: float) -> void:
	if not enabled_tracing:
		return
	_append_current_point()


func clear_trace() -> void:
	clear_points()
	_rebuild_mesh()


func set_target(node: Node3D) -> void:
	target_node = node


func set_point_callable(source: Callable) -> void:
	point_callable = source


func _append_current_point() -> void:
	var point: Variant = _sample_world_point()
	if point == null:
		return

	var sampled: Vector3 = point as Vector3
	if local_space:
		sampled = to_local(sampled)

	var count: int = get_point_count()
	var should_append: bool = true
	if count > 0:
		var last: Vector3 = get_point_position(count - 1)
		should_append = last.distance_to(sampled) >= maxf(0.0, min_distance)
	if not should_append:
		return

	add_point(sampled)
	if max_points > 0:
		while get_point_count() > max_points:
			remove_point(0)
	_rebuild_mesh()


func _sample_world_point() -> Variant:
	if point_callable.is_valid():
		var v: Variant = point_callable.call()
		if v is Vector3:
			return v
	if target_node != null and is_instance_valid(target_node):
		return target_node.global_position
	return null


func clear_points() -> void:
	_points.clear()


func add_point(p: Vector3) -> void:
	_points.append(p)


func remove_point(index: int) -> void:
	if index < 0 or index >= _points.size():
		return
	_points.remove_at(index)


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



