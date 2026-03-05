class_name GShapesCurveIntersections2D
extends Node2D

var source_a: GShapesPolylineMobject
var source_b: GShapesPolylineMobject
var callable_a: Callable
var callable_b: Callable
var marker_radius: float = 4.0
var marker_color: Color = Color(0.86, 1.0, 0.55, 0.95)
var max_markers: int = 64
var enabled_detection: bool = true

var _points: PackedVector2Array = PackedVector2Array()


func _process(_delta: float) -> void:
	if not enabled_detection:
		_points = PackedVector2Array()
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	_points = PackedVector2Array()
	var a_pts: PackedVector2Array = _sample_a()
	var b_pts: PackedVector2Array = _sample_b()
	if a_pts.size() < 2 or b_pts.size() < 2:
		queue_redraw()
		return

	var out: Array[Vector2] = []
	for i in range(a_pts.size() - 1):
		var a0: Vector2 = a_pts[i]
		var a1: Vector2 = a_pts[i + 1]
		for j in range(b_pts.size() - 1):
			var b0: Vector2 = b_pts[j]
			var b1: Vector2 = b_pts[j + 1]
			var hit: Variant = _segment_intersection(a0, a1, b0, b1)
			if hit is Vector2:
				out.append(hit as Vector2)
				if out.size() >= max_markers:
					_points = PackedVector2Array(out)
					queue_redraw()
					return

	_points = PackedVector2Array(out)
	queue_redraw()


func _sample_a() -> PackedVector2Array:
	if callable_a.is_valid():
		var v: Variant = callable_a.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_a != null and is_instance_valid(source_a):
		return source_a.points
	return PackedVector2Array()


func _sample_b() -> PackedVector2Array:
	if callable_b.is_valid():
		var v: Variant = callable_b.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_b != null and is_instance_valid(source_b):
		return source_b.points
	return PackedVector2Array()


func _segment_intersection(p: Vector2, p2: Vector2, q: Vector2, q2: Vector2) -> Variant:
	var r: Vector2 = p2 - p
	var s: Vector2 = q2 - q
	var denom: float = r.cross(s)
	if absf(denom) <= 0.000001:
		return null

	var qp: Vector2 = q - p
	var t: float = qp.cross(s) / denom
	var u: float = qp.cross(r) / denom
	if t < 0.0 or t > 1.0 or u < 0.0 or u > 1.0:
		return null
	return p + r * t


func _draw() -> void:
	for i in range(_points.size()):
		draw_circle(_points[i], marker_radius, marker_color)



