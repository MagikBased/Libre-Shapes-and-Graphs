class_name PortLyapunovPlot2D
extends PortObject2D

var axes: GraphAxes2D
var map_callable: Callable
var derivative_callable: Callable
var parameter_min: float = 2.5
var parameter_max: float = 4.0
var parameter_samples: int = 220
var initial_value: float = 0.5
var settle_iterations: int = 80
var measure_iterations: int = 120
var epsilon: float = 0.000001
var stroke_width: float = 2.0
var auto_update: bool = true
var draw_progress: float = 1.0

var _points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	rebuild_curve()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild_curve()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func rebuild_curve() -> void:
	_points.clear()
	if axes == null:
		queue_redraw()
		return

	var p_min: float = minf(parameter_min, parameter_max)
	var p_max: float = maxf(parameter_min, parameter_max)
	var p_count: int = maxi(2, parameter_samples)
	var settle: int = maxi(0, settle_iterations)
	var measure: int = maxi(1, measure_iterations)

	var out: PackedVector2Array = PackedVector2Array()
	out.resize(p_count)
	for i in range(p_count):
		var t: float = float(i) / float(p_count - 1)
		var p: float = lerpf(p_min, p_max, t)
		var x: float = initial_value

		for _s in range(settle):
			x = _map_value(x, p)

		var sum_log: float = 0.0
		for _m in range(measure):
			x = _map_value(x, p)
			var d: float = _map_derivative(x, p)
			sum_log += log(maxf(epsilon, absf(d)))
		var lambda: float = sum_log / float(measure)
		out[i] = axes.c2p(p, lambda)

	_points = out
	queue_redraw()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _map_derivative(x: float, parameter: float) -> float:
	if derivative_callable.is_valid():
		var v: Variant = derivative_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	var h: float = 0.00001
	var y0: float = _map_value(x - h, parameter)
	var y1: float = _map_value(x + h, parameter)
	return (y1 - y0) / (2.0 * h)


func _draw() -> void:
	if _points.size() < 2:
		return
	var segment_count: int = _points.size() - 1
	var max_segment: int = clampi(int(floor(float(segment_count) * draw_progress)), 0, segment_count)
	for i in range(max_segment):
		draw_line(_points[i], _points[i + 1], color, stroke_width)
