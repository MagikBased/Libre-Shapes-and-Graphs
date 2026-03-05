class_name LsgGraphInflectionPoints2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var x_min_value: float = -6.0
var x_max_value: float = 6.0
var sample_count: int = 260
var curvature_epsilon: float = 0.0001
var merge_epsilon: float = 0.06
var max_points: int = 40
var marker_radius: float = 4.0
var marker_color: Color = Color(0.9, 0.62, 1.0, 0.95)
var show_labels: bool = true
var auto_update: bool = true

var _points: Array[Vector2] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_points.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	var n: int = maxi(5, sample_count)
	var dx: float = (right - left) / float(n - 1)
	var prev_curv: float = _curvature_proxy_at(left)

	for i in range(1, n - 1):
		var x: float = left + float(i) * dx
		var curv: float = _curvature_proxy_at(x)
		if prev_curv > curvature_epsilon and curv < -curvature_epsilon:
			_add_point(Vector2(x, _eval_y(x)))
		elif prev_curv < -curvature_epsilon and curv > curvature_epsilon:
			_add_point(Vector2(x, _eval_y(x)))

		if _points.size() >= max_points:
			break
		prev_curv = curv

	_update_labels()
	queue_redraw()


func inflection_points() -> Array[Vector2]:
	return _points.duplicate()


func _curvature_proxy_at(x: float) -> float:
	var h: float = 0.003
	var y0: float = _eval_y(x - h)
	var y1: float = _eval_y(x)
	var y2: float = _eval_y(x + h)
	return (y2 - 2.0 * y1 + y0) / (h * h)


func _eval_y(x: float) -> float:
	if function_callable.is_valid():
		var v: Variant = function_callable.call(x)
		if v is float or v is int:
			return float(v)
	if graph != null:
		return graph.eval_y(x)
	return 0.0


func _add_point(p: Vector2) -> void:
	for q in _points:
		if absf(q.x - p.x) <= merge_epsilon:
			return
	_points.append(p)


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or _label_layer == null or axes == null:
		return
	for p in _points:
		var l: Label = Label.new()
		l.text = "infl"
		l.add_theme_font_size_override("font_size", 13)
		l.modulate = marker_color
		l.position = axes.c2p(p.x, p.y) + Vector2(8.0, -20.0)
		_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return
	for p in _points:
		var local_p: Vector2 = axes.c2p(p.x, p.y)
		draw_circle(local_p, marker_radius, marker_color)
