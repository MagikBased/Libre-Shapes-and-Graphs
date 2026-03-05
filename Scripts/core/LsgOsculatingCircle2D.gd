class_name LsgOsculatingCircle2D
extends Node2D

var source_curve: LsgPolylineMobject
var source_callable: Callable
var alpha: float = 0.0
var min_radius: float = 8.0
var max_radius: float = 600.0
var circle_color: Color = Color(0.56, 0.95, 1.0, 0.85)
var radius_color: Color = Color(1.0, 0.74, 0.36, 0.9)
var point_color: Color = Color(0.86, 1.0, 0.56, 0.95)
var line_width: float = 2.0
var enabled_circle: bool = true

var _point: Vector2 = Vector2.ZERO
var _center: Vector2 = Vector2.ZERO
var _radius: float = 0.0
var _valid: bool = false


func _process(_delta: float) -> void:
	if not enabled_circle:
		_valid = false
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	_valid = false
	var pts: PackedVector2Array = _sample_points()
	if pts.size() < 3:
		queue_redraw()
		return

	var a: float = clampf(alpha, 0.0, 1.0)
	var eps: float = 0.004
	var a0: float = clampf(a - eps, 0.0, 1.0)
	var a1: float = clampf(a, 0.0, 1.0)
	var a2: float = clampf(a + eps, 0.0, 1.0)

	var p0: Vector2 = GShapes.PathUtils.sample_polyline(pts, a0, false)
	var p1: Vector2 = GShapes.PathUtils.sample_polyline(pts, a1, false)
	var p2: Vector2 = GShapes.PathUtils.sample_polyline(pts, a2, false)

	var d1: Vector2 = p1 - p0
	var d2: Vector2 = p2 - p1
	var len1: float = d1.length()
	var len2: float = d2.length()
	if len1 <= 0.0001 or len2 <= 0.0001:
		queue_redraw()
		return

	var t1: Vector2 = d1 / len1
	var t2: Vector2 = d2 / len2
	var turn: float = t1.angle_to(t2)
	var avg_len: float = (len1 + len2) * 0.5
	if avg_len <= 0.0001:
		queue_redraw()
		return

	var curvature_proxy: float = turn / avg_len
	if absf(curvature_proxy) <= 0.00001:
		queue_redraw()
		return

	var radius: float = 1.0 / absf(curvature_proxy)
	radius = clampf(radius, min_radius, max_radius)

	var tangent: Vector2 = (t1 + t2)
	if tangent.length() <= 0.0001:
		tangent = t1
	tangent = tangent.normalized()

	var sign_value: float = 1.0 if curvature_proxy >= 0.0 else -1.0
	var normal: Vector2 = Vector2(-tangent.y, tangent.x) * sign_value

	_point = p1
	_center = p1 + normal * radius
	_radius = radius
	_valid = true
	queue_redraw()


func _sample_points() -> PackedVector2Array:
	if source_callable.is_valid():
		var v: Variant = source_callable.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_curve != null and is_instance_valid(source_curve):
		return source_curve.points
	return PackedVector2Array()


func _draw() -> void:
	if not _valid:
		return
	draw_arc(_center, _radius, 0.0, TAU, 96, circle_color, line_width, true)
	draw_line(_point, _center, radius_color, line_width, true)
	draw_circle(_point, 4.0, point_color)
