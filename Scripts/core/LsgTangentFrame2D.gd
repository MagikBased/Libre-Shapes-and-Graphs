class_name LsgTangentFrame2D
extends Node2D

var source_curve: LsgPolylineMobject
var source_callable: Callable
var alpha: float = 0.0
var frame_scale: float = 70.0
var tangent_color: Color = Color(1.0, 0.72, 0.35, 0.95)
var normal_color: Color = Color(0.52, 0.95, 1.0, 0.95)
var anchor_color: Color = Color(0.86, 1.0, 0.56, 0.95)
var line_width: float = 2.2
var enabled_frame: bool = true

var _anchor: Vector2 = Vector2.ZERO
var _tangent: Vector2 = Vector2.RIGHT
var _normal: Vector2 = Vector2.UP


func _process(_delta: float) -> void:
	if not enabled_frame:
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	var pts: PackedVector2Array = _sample_points()
	if pts.size() < 2:
		queue_redraw()
		return

	var a: float = clampf(alpha, 0.0, 1.0)
	_anchor = GShapes.PathUtils.sample_polyline(pts, a, false)
	var eps: float = 0.003
	var a0: float = clampf(a - eps, 0.0, 1.0)
	var a1: float = clampf(a + eps, 0.0, 1.0)
	var p0: Vector2 = GShapes.PathUtils.sample_polyline(pts, a0, false)
	var p1: Vector2 = GShapes.PathUtils.sample_polyline(pts, a1, false)
	var d: Vector2 = p1 - p0
	if d.length() <= 0.0001:
		d = Vector2.RIGHT
	_tangent = d.normalized()
	_normal = Vector2(-_tangent.y, _tangent.x)
	queue_redraw()


func anchor_local() -> Vector2:
	return _anchor


func tangent_local() -> Vector2:
	return _tangent


func normal_local() -> Vector2:
	return _normal


func _sample_points() -> PackedVector2Array:
	if source_callable.is_valid():
		var v: Variant = source_callable.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_curve != null and is_instance_valid(source_curve):
		return source_curve.points
	return PackedVector2Array()


func _draw() -> void:
	if not enabled_frame:
		return
	var tangent_end: Vector2 = _anchor + _tangent * frame_scale
	var normal_end: Vector2 = _anchor + _normal * frame_scale
	draw_line(_anchor, tangent_end, tangent_color, line_width, true)
	draw_line(_anchor, normal_end, normal_color, line_width, true)
	draw_circle(_anchor, 4.0, anchor_color)
