class_name GShapesBisectionIteration2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var left_x: float = -2.0
var right_x: float = 3.0
var iteration_count: int = 6
var zero_epsilon: float = 0.00001
var endpoint_color: Color = Color(0.4, 0.9, 1.0, 0.92)
var midpoint_color: Color = Color(1.0, 0.74, 0.32, 0.95)
var interval_color: Color = Color(0.9, 0.95, 1.0, 0.85)
var line_width: float = 2.0
var point_radius: float = 3.8
var show_labels: bool = true
var auto_update: bool = true

var _a_points: Array[Vector2] = []
var _b_points: Array[Vector2] = []
var _m_points: Array[Vector2] = []
var _interval_segments: Array[PackedVector2Array] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_a_points.clear()
	_b_points.clear()
	_m_points.clear()
	_interval_segments.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var a: float = minf(left_x, right_x)
	var b: float = maxf(left_x, right_x)
	var fa: float = _eval_y(a)
	var fb: float = _eval_y(b)
	var max_iter: int = maxi(0, iteration_count)

	for _i in range(max_iter + 1):
		var m: float = 0.5 * (a + b)
		var fm: float = _eval_y(m)

		_a_points.append(Vector2(a, fa))
		_b_points.append(Vector2(b, fb))
		_m_points.append(Vector2(m, fm))
		_interval_segments.append(PackedVector2Array([
			axes.c2p(a, 0.0),
			axes.c2p(b, 0.0),
		]))

		if absf(fm) <= zero_epsilon:
			break
		if fa * fm <= 0.0:
			b = m
			fb = fm
		else:
			a = m
			fa = fm

	_update_labels()
	queue_redraw()


func current_estimate() -> float:
	if _m_points.is_empty():
		return 0.5 * (left_x + right_x)
	return _m_points[_m_points.size() - 1].x


func _eval_y(x: float) -> float:
	if function_callable.is_valid():
		var v: Variant = function_callable.call(x)
		if v is float or v is int:
			return float(v)
	if graph != null:
		return graph.eval_y(x)
	return 0.0


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or _label_layer == null or axes == null or _m_points.is_empty():
		return
	var last_i: int = _m_points.size() - 1
	var m: Vector2 = _m_points[last_i]
	var l: Label = Label.new()
	l.text = "mid=%.4f" % m.x
	l.add_theme_font_size_override("font_size", 13)
	l.modulate = midpoint_color
	l.position = axes.c2p(m.x, m.y) + Vector2(8.0, -20.0)
	_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return

	for seg in _interval_segments:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], interval_color, line_width)

	for p in _a_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, endpoint_color)
	for p in _b_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, endpoint_color)
	for p in _m_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, midpoint_color)



