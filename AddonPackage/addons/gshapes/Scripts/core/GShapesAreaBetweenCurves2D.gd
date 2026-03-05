class_name GShapesAreaBetweenCurves2D
extends GShapesObject2D

var axes: GraphAxes2D
var top_graph: FunctionPlot2D
var bottom_graph: FunctionPlot2D
var top_callable: Callable
var bottom_callable: Callable
var x_min_value: float = -2.0
var x_max_value: float = 2.0
var sample_count: int = 140
var fill_alpha: float = 0.24
var stroke_width: float = 1.5
var draw_progress: float = 1.0
var top_color: Color = Color(0.32, 0.86, 1.0, 1.0)
var bottom_color: Color = Color(1.0, 0.72, 0.34, 1.0)

var _top_points: PackedVector2Array = PackedVector2Array()
var _bottom_points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	recompute_polygon()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_polygon() -> void:
	_top_points.clear()
	_bottom_points.clear()
	if axes == null:
		queue_redraw()
		return

	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	var n: int = maxi(2, sample_count)
	for i in range(n):
		var t: float = float(i) / float(n - 1)
		var x: float = lerpf(left, right, t)
		var y_top: float = _eval_top(x)
		var y_bottom: float = _eval_bottom(x)
		_top_points.append(axes.c2p(x, y_top))
		_bottom_points.append(axes.c2p(x, y_bottom))

	queue_redraw()


func approximate_area(samples: int = 240) -> float:
	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	if right - left <= 0.000001:
		return 0.0
	var n: int = maxi(4, samples)
	var dx: float = (right - left) / float(n - 1)
	var sum: float = 0.0
	for i in range(n):
		var x: float = left + float(i) * dx
		var h: float = _eval_top(x) - _eval_bottom(x)
		var w: float = 1.0
		if i == 0 or i == n - 1:
			w = 0.5
		sum += h * w
	return sum * dx


func _eval_top(x: float) -> float:
	if top_callable.is_valid():
		var v: Variant = top_callable.call(x)
		if v is float or v is int:
			return float(v)
	if top_graph != null:
		return top_graph.eval_y(x)
	return 0.0


func _eval_bottom(x: float) -> float:
	if bottom_callable.is_valid():
		var v: Variant = bottom_callable.call(x)
		if v is float or v is int:
			return float(v)
	if bottom_graph != null:
		return bottom_graph.eval_y(x)
	return 0.0


func _draw() -> void:
	if _top_points.size() < 2 or _bottom_points.size() < 2:
		return

	var n: int = mini(_top_points.size(), _bottom_points.size())
	var used: int = clampi(int(ceil(float(n) * draw_progress)), 2, n)
	var fill: Color = Color(color.r, color.g, color.b, clampf(fill_alpha, 0.0, 1.0))
	# Draw as triangle strips per segment to avoid self-intersecting global polygons
	# when curves cross, which can fail Godot triangulation.
	for i in range(used - 1):
		var t0: Vector2 = _top_points[i]
		var t1: Vector2 = _top_points[i + 1]
		var b0: Vector2 = _bottom_points[i]
		var b1: Vector2 = _bottom_points[i + 1]
		if not (_is_valid_point(t0) and _is_valid_point(t1) and _is_valid_point(b0) and _is_valid_point(b1)):
			continue

		var tri_a: PackedVector2Array = PackedVector2Array([t0, t1, b0])
		var tri_b: PackedVector2Array = PackedVector2Array([t1, b1, b0])
		if absf((t1 - t0).cross(b0 - t0)) > 0.000001:
			draw_colored_polygon(tri_a, fill)
		if absf((b1 - t1).cross(b0 - t1)) > 0.000001:
			draw_colored_polygon(tri_b, fill)

	for i in range(used - 1):
		var top_a: Vector2 = _top_points[i]
		var top_b: Vector2 = _top_points[i + 1]
		var bottom_a: Vector2 = _bottom_points[i]
		var bottom_b: Vector2 = _bottom_points[i + 1]
		if _is_valid_point(top_a) and _is_valid_point(top_b):
			draw_line(top_a, top_b, top_color, stroke_width)
		if _is_valid_point(bottom_a) and _is_valid_point(bottom_b):
			draw_line(bottom_a, bottom_b, bottom_color, stroke_width)


func _is_valid_point(p: Vector2) -> bool:
	return is_finite(p.x) and is_finite(p.y)



