class_name LsgRiemannRectangles2D
extends LsgObject2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var x_min_value: float = -2.0
var x_max_value: float = 2.0
var baseline_y: float = 0.0
var delta_x: float = 0.4
var sample_mode: StringName = &"left"
var fill_alpha: float = 0.26
var stroke_width: float = 1.3
var draw_progress: float = 1.0
var positive_color: Color = Color(0.2, 0.88, 0.55, 1.0)
var negative_color: Color = Color(1.0, 0.36, 0.34, 1.0)

var _rectangles: Array[PackedVector2Array] = []
var _fill_colors: Array[Color] = []


func _ready() -> void:
	recompute_rectangles()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_rectangles() -> void:
	_rectangles.clear()
	_fill_colors.clear()
	if axes == null or graph == null:
		queue_redraw()
		return

	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	var width: float = maxf(0.0001, absf(delta_x))
	if right - left <= 0.000001:
		queue_redraw()
		return

	var count: int = maxi(1, int(ceil((right - left) / width)))
	for i in range(count):
		var x0: float = left + float(i) * width
		if x0 >= right:
			break
		var x1: float = minf(right, x0 + width)
		var sample_x: float = _sample_x_for_rect(x0, x1)
		var y: float = graph.eval_y(sample_x)

		var p0: Vector2 = axes.c2p(x0, baseline_y)
		var p1: Vector2 = axes.c2p(x0, y)
		var p2: Vector2 = axes.c2p(x1, y)
		var p3: Vector2 = axes.c2p(x1, baseline_y)
		_rectangles.append(PackedVector2Array([p0, p1, p2, p3]))

		var base_color: Color = positive_color if y >= baseline_y else negative_color
		_fill_colors.append(Color(base_color.r, base_color.g, base_color.b, clampf(fill_alpha, 0.0, 1.0)))

	queue_redraw()


func _sample_x_for_rect(x0: float, x1: float) -> float:
	var mode: String = String(sample_mode).to_lower()
	if mode == "right":
		return x1
	if mode == "midpoint":
		return 0.5 * (x0 + x1)
	return x0


func _draw() -> void:
	if _rectangles.is_empty():
		return

	var max_count: int = int(ceil(float(_rectangles.size()) * draw_progress))
	max_count = clampi(max_count, 0, _rectangles.size())
	for i in range(max_count):
		var poly: PackedVector2Array = _rectangles[i]
		if poly.size() < 3:
			continue
		draw_colored_polygon(poly, _fill_colors[i])
		var line_color: Color = color
		if line_color.a <= 0.001:
			line_color = Color(1.0, 1.0, 1.0, 0.75)
		for j in range(poly.size()):
			var a: Vector2 = poly[j]
			var b: Vector2 = poly[(j + 1) % poly.size()]
			draw_line(a, b, line_color, stroke_width)
