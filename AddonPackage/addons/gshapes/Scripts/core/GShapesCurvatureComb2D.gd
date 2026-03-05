class_name GShapesCurvatureComb2D
extends Node2D

var source_curve: GShapesPolylineMobject
var source_callable: Callable
var sample_stride: int = 6
var comb_scale: float = 42.0
var max_comb_length: float = 80.0
var comb_color: Color = Color(0.56, 0.96, 1.0, 0.86)
var comb_width: float = 1.5
var enabled_comb: bool = true

var _segments: Array[Vector2] = []


func _process(_delta: float) -> void:
	if not enabled_comb:
		_segments.clear()
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	_segments.clear()
	var pts: PackedVector2Array = _sample_points()
	if pts.size() < 3:
		queue_redraw()
		return

	var stride: int = maxi(1, sample_stride)
	for i in range(1, pts.size() - 1):
		if i % stride != 0:
			continue
		var p0: Vector2 = pts[i - 1]
		var p1: Vector2 = pts[i]
		var p2: Vector2 = pts[i + 1]

		var t_prev: Vector2 = p1 - p0
		var t_next: Vector2 = p2 - p1
		var len_prev: float = t_prev.length()
		var len_next: float = t_next.length()
		if len_prev <= 0.0001 or len_next <= 0.0001:
			continue

		var n_prev: Vector2 = t_prev / len_prev
		var n_next: Vector2 = t_next / len_next
		var turn: float = n_prev.angle_to(n_next)
		var avg_len: float = (len_prev + len_next) * 0.5
		if avg_len <= 0.0001:
			continue

		var curvature_proxy: float = turn / avg_len
		var tangent: Vector2 = (n_prev + n_next)
		if tangent.length() <= 0.0001:
			tangent = n_prev
		tangent = tangent.normalized()
		var normal: Vector2 = Vector2(-tangent.y, tangent.x)

		var length_px: float = clampf(curvature_proxy * comb_scale, -max_comb_length, max_comb_length)
		var end_point: Vector2 = p1 + normal * length_px
		_segments.append(p1)
		_segments.append(end_point)

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
	for i in range(0, _segments.size(), 2):
		if i + 1 >= _segments.size():
			break
		draw_line(_segments[i], _segments[i + 1], comb_color, comb_width, true)



