class_name GShapesNormalOffsetCurve2D
extends GShapesPolylineMobject

var source_curve: GShapesPolylineMobject
var source_callable: Callable
var offset_distance: float = 28.0
var sample_count: int = 220
var alpha_start: float = 0.0
var alpha_end: float = 1.0
var auto_update: bool = true


func _process(_delta: float) -> void:
	if auto_update:
		rebuild_offset()


func rebuild_offset() -> void:
	var src: PackedVector2Array = _sample_points()
	if src.size() < 2:
		points = PackedVector2Array()
		queue_redraw()
		return

	var a0: float = clampf(alpha_start, 0.0, 1.0)
	var a1: float = clampf(alpha_end, 0.0, 1.0)
	if a1 < a0:
		var tmp: float = a0
		a0 = a1
		a1 = tmp

	var count: int = maxi(3, sample_count)
	var out := PackedVector2Array()
	out.resize(count)

	for i in range(count):
		var t: float = float(i) / float(count - 1)
		var a: float = lerpf(a0, a1, t)
		var p: Vector2 = GShapesPathUtils.sample_polyline(src, a, false)
		var eps: float = 0.003
		var a_prev: float = clampf(a - eps, 0.0, 1.0)
		var a_next: float = clampf(a + eps, 0.0, 1.0)
		var p_prev: Vector2 = GShapesPathUtils.sample_polyline(src, a_prev, false)
		var p_next: Vector2 = GShapesPathUtils.sample_polyline(src, a_next, false)
		var d: Vector2 = p_next - p_prev
		if d.length() <= 0.0001:
			d = Vector2.RIGHT
		var tangent: Vector2 = d.normalized()
		var normal: Vector2 = Vector2(-tangent.y, tangent.x)
		out[i] = p + normal * offset_distance

	points = out
	queue_redraw()


func _sample_points() -> PackedVector2Array:
	if source_callable.is_valid():
		var v: Variant = source_callable.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_curve != null and is_instance_valid(source_curve):
		return source_curve.points
	return PackedVector2Array()




