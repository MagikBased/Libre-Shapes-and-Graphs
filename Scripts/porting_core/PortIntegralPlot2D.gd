class_name PortIntegralPlot2D
extends PortObject2D

var axes: GraphAxes2D
var source_graph: FunctionPlot2D
var source_callable: Callable
var integration_origin_x: float = 0.0
var sample_count: int = 180
var integration_steps: int = 24
var stroke_width: float = 2.3
var draw_progress: float = 1.0
var render_mode: StringName = &"polyline"
var auto_update: bool = true

var _points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	recompute_points()


func _process(_delta: float) -> void:
	if auto_update:
		recompute_points()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_points() -> void:
	_points.clear()
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(2, sample_count)
	var left: float = axes.x_min
	var right: float = axes.x_max
	for i in range(n):
		var t: float = float(i) / float(n - 1)
		var x: float = lerpf(left, right, t)
		var area: float = eval_integral(x)
		_points.append(axes.c2p(x, area))

	queue_redraw()


func eval_integral(x: float) -> float:
	if is_equal_approx(x, integration_origin_x):
		return 0.0
	var a: float = integration_origin_x
	var b: float = x
	var sign_value: float = 1.0
	if b < a:
		var tmp: float = a
		a = b
		b = tmp
		sign_value = -1.0
	var steps: int = maxi(4, integration_steps)
	var dx: float = (b - a) / float(steps)
	var sum: float = 0.0
	for i in range(steps + 1):
		var xi: float = a + float(i) * dx
		var weight: float = 1.0
		if i == 0 or i == steps:
			weight = 0.5
		sum += _eval_y(xi) * weight
	return sign_value * sum * dx


func _eval_y(x: float) -> float:
	if source_callable.is_valid():
		var v: Variant = source_callable.call(x)
		if v is float or v is int:
			return float(v)
	if source_graph != null:
		return source_graph.eval_y(x)
	return 0.0


func _draw() -> void:
	if _points.size() < 2:
		return
	var segment_count: int = _points.size() - 1
	var max_segment: int = clampi(int(floor(float(segment_count) * draw_progress)), 0, segment_count)
	for i in range(max_segment):
		if String(render_mode).to_lower() == "dashed" and i % 2 == 1:
			continue
		draw_line(_points[i], _points[i + 1], color, stroke_width)
