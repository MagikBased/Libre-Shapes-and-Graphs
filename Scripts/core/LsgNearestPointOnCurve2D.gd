class_name LsgNearestPointOnCurve2D
extends Node2D

var source_curve: LsgPolylineMobject
var source_callable: Callable
var probe_node: Node2D
var probe_callable: Callable
var sample_count: int = 260
var connector_color: Color = Color(0.56, 0.95, 1.0, 0.88)
var curve_point_color: Color = Color(1.0, 0.74, 0.36, 0.96)
var probe_point_color: Color = Color(0.84, 1.0, 0.56, 0.96)
var line_width: float = 2.0
var marker_radius: float = 4.0
var enabled_helper: bool = true

var _probe_local: Vector2 = Vector2.ZERO
var _nearest_local: Vector2 = Vector2.ZERO
var _valid: bool = false


func _process(_delta: float) -> void:
	if not enabled_helper:
		_valid = false
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	_valid = false
	var src: PackedVector2Array = _sample_curve_points()
	if src.size() < 2:
		queue_redraw()
		return

	_probe_local = _sample_probe_local()
	var sampled: PackedVector2Array = GShapes.PathUtils.resample_polyline(src, maxi(3, sample_count), false)
	if sampled.is_empty():
		queue_redraw()
		return

	var best_d2: float = INF
	var best: Vector2 = sampled[0]
	for i in range(sampled.size()):
		var p: Vector2 = sampled[i]
		var d2: float = p.distance_squared_to(_probe_local)
		if d2 < best_d2:
			best_d2 = d2
			best = p

	_nearest_local = best
	_valid = true
	queue_redraw()


func _sample_curve_points() -> PackedVector2Array:
	if source_callable.is_valid():
		var v: Variant = source_callable.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_curve != null and is_instance_valid(source_curve):
		return source_curve.points
	return PackedVector2Array()


func _sample_probe_local() -> Vector2:
	if probe_callable.is_valid():
		var v: Variant = probe_callable.call()
		if v is Vector2:
			return to_local(v as Vector2)
	if probe_node != null and is_instance_valid(probe_node):
		return to_local(probe_node.global_position)
	return Vector2.ZERO


func _draw() -> void:
	if not _valid:
		return
	draw_line(_probe_local, _nearest_local, connector_color, line_width, true)
	draw_circle(_nearest_local, marker_radius, curve_point_color)
	draw_circle(_probe_local, marker_radius, probe_point_color)
