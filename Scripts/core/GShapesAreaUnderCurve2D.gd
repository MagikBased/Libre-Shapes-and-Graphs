class_name GShapesAreaUnderCurve2D
extends GShapesObject2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var x_min_value: float = -2.0
var x_max_value: float = 2.0
var baseline_y: float = 0.0
var sample_count: int = 120
var fill_alpha: float = 0.28
var stroke_width: float = 1.5
var draw_progress: float = 1.0

var _polygon: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	recompute_polygon()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_polygon() -> void:
	_polygon.clear()
	if axes == null or graph == null:
		queue_redraw()
		return

	var n: int = maxi(8, sample_count)
	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)

	_polygon.append(axes.c2p(left, baseline_y))
	for i in range(n):
		var t: float = float(i) / float(n - 1)
		var x: float = lerpf(left, right, t)
		var y: float = graph.eval_y(x)
		_polygon.append(axes.c2p(x, y))
	_polygon.append(axes.c2p(right, baseline_y))

	queue_redraw()


func _draw() -> void:
	if _polygon.size() < 3:
		return

	var max_count: int = int(ceil(float(_polygon.size()) * draw_progress))
	max_count = clampi(max_count, 3, _polygon.size())
	var partial: PackedVector2Array = PackedVector2Array()
	for i in range(max_count):
		partial.append(_polygon[i])
	if partial.size() < 3:
		return

	var fill: Color = Color(color.r, color.g, color.b, clampf(fill_alpha, 0.0, 1.0))
	draw_colored_polygon(partial, fill)
	for i in range(partial.size() - 1):
		draw_line(partial[i], partial[i + 1], color, stroke_width)



