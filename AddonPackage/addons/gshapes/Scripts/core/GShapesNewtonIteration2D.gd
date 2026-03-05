class_name GShapesNewtonIteration2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var initial_x: float = 1.0
var iteration_count: int = 4
var derivative_h: float = 0.001
var derivative_epsilon: float = 0.00001
var tangent_color: Color = Color(1.0, 0.72, 0.32, 0.92)
var step_color: Color = Color(0.4, 0.9, 1.0, 0.92)
var point_color: Color = Color(1.0, 0.88, 0.4, 0.96)
var line_width: float = 2.0
var point_radius: float = 3.8
var auto_update: bool = true
var show_labels: bool = true

var _graph_points: Array[Vector2] = []
var _tangent_segments: Array[PackedVector2Array] = []
var _step_segments: Array[PackedVector2Array] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_graph_points.clear()
	_tangent_segments.clear()
	_step_segments.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var x_n: float = initial_x
	var max_iter: int = maxi(0, iteration_count)
	for _i in range(max_iter + 1):
		var y_n: float = _eval_y(x_n)
		_graph_points.append(Vector2(x_n, y_n))
		if _i >= max_iter:
			break

		var m: float = _eval_derivative(x_n)
		if absf(m) <= derivative_epsilon:
			break

		var x_next: float = x_n - y_n / m
		_tangent_segments.append(PackedVector2Array([
			axes.c2p(x_n, y_n),
			axes.c2p(x_next, 0.0),
		]))

		var y_next: float = _eval_y(x_next)
		_step_segments.append(PackedVector2Array([
			axes.c2p(x_next, 0.0),
			axes.c2p(x_next, y_next),
		]))

		x_n = x_next

	_update_labels()
	queue_redraw()


func current_estimate() -> float:
	if _graph_points.is_empty():
		return initial_x
	return _graph_points[_graph_points.size() - 1].x


func _eval_y(x: float) -> float:
	if function_callable.is_valid():
		var v: Variant = function_callable.call(x)
		if v is float or v is int:
			return float(v)
	if graph != null:
		return graph.eval_y(x)
	return 0.0


func _eval_derivative(x: float) -> float:
	var h: float = maxf(0.000001, absf(derivative_h))
	var y0: float = _eval_y(x - h)
	var y1: float = _eval_y(x + h)
	return (y1 - y0) / (2.0 * h)


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or _label_layer == null or axes == null:
		return
	for i in range(_graph_points.size()):
		var p: Vector2 = _graph_points[i]
		var l: Label = Label.new()
		l.text = "x%d=%.2f" % [i, p.x]
		l.add_theme_font_size_override("font_size", 12)
		l.modulate = point_color
		l.position = axes.c2p(p.x, p.y) + Vector2(8.0, -18.0)
		_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return

	for seg in _tangent_segments:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], tangent_color, line_width)
	for seg in _step_segments:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], step_color, line_width)

	for p in _graph_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, point_color)



