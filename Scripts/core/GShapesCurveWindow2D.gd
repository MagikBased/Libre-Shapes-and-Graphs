class_name GShapesCurveWindow2D
extends GShapesPolylineMobject

var source_curve: GShapesPolylineMobject
var source_callable: Callable
var alpha_start: float = 0.0
var alpha_end: float = 0.25
var window_samples: int = 72
var auto_update: bool = true


func _process(_delta: float) -> void:
	if auto_update:
		rebuild_window()


func rebuild_window() -> void:
	var source_points: PackedVector2Array = _sample_points()
	if source_points.size() < 2:
		points = PackedVector2Array()
		queue_redraw()
		return

	var a0: float = clampf(alpha_start, 0.0, 1.0)
	var a1: float = clampf(alpha_end, 0.0, 1.0)
	if a1 < a0:
		var tmp: float = a0
		a0 = a1
		a1 = tmp

	var count: int = maxi(2, window_samples)
	var out := PackedVector2Array()
	out.resize(count)
	for i in range(count):
		var t: float = float(i) / float(count - 1)
		var a: float = lerpf(a0, a1, t)
		out[i] = GShapesPathUtils.sample_polyline(source_points, a, false)

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




