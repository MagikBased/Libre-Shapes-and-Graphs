class_name LsgGraphExtrema2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var x_min_value: float = -6.0
var x_max_value: float = 6.0
var sample_count: int = 260
var slope_epsilon: float = 0.0001
var merge_epsilon: float = 0.06
var max_points: int = 40
var max_color: Color = Color(1.0, 0.45, 0.45, 0.95)
var min_color: Color = Color(0.4, 0.9, 1.0, 0.95)
var marker_radius: float = 4.0
var show_labels: bool = true
var auto_update: bool = true

var _maxima: Array[Vector2] = []
var _minima: Array[Vector2] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_maxima.clear()
	_minima.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	var n: int = maxi(5, sample_count)
	var dx: float = (right - left) / float(n - 1)
	var prev_slope: float = _slope_at(left)

	for i in range(1, n - 1):
		var x: float = left + float(i) * dx
		var slope: float = _slope_at(x)

		if prev_slope > slope_epsilon and slope < -slope_epsilon:
			_add_extremum(_maxima, Vector2(x, _eval_y(x)))
		elif prev_slope < -slope_epsilon and slope > slope_epsilon:
			_add_extremum(_minima, Vector2(x, _eval_y(x)))

		if _maxima.size() + _minima.size() >= max_points:
			break
		prev_slope = slope

	_update_labels()
	queue_redraw()


func maxima_points() -> Array[Vector2]:
	return _maxima.duplicate()


func minima_points() -> Array[Vector2]:
	return _minima.duplicate()


func _slope_at(x: float) -> float:
	var h: float = 0.002
	var y0: float = _eval_y(x - h)
	var y1: float = _eval_y(x + h)
	return (y1 - y0) / (2.0 * h)


func _eval_y(x: float) -> float:
	if function_callable.is_valid():
		var v: Variant = function_callable.call(x)
		if v is float or v is int:
			return float(v)
	if graph != null:
		return graph.eval_y(x)
	return 0.0


func _add_extremum(store: Array[Vector2], p: Vector2) -> void:
	for q in store:
		if absf(q.x - p.x) <= merge_epsilon:
			return
	store.append(p)


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or _label_layer == null or axes == null:
		return

	for p in _maxima:
		var l: Label = Label.new()
		l.text = "max"
		l.add_theme_font_size_override("font_size", 13)
		l.modulate = max_color
		l.position = axes.c2p(p.x, p.y) + Vector2(8.0, -24.0)
		_label_layer.add_child(l)

	for p in _minima:
		var l: Label = Label.new()
		l.text = "min"
		l.add_theme_font_size_override("font_size", 13)
		l.modulate = min_color
		l.position = axes.c2p(p.x, p.y) + Vector2(8.0, 8.0)
		_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return
	for p in _maxima:
		var local_p: Vector2 = axes.c2p(p.x, p.y)
		draw_circle(local_p, marker_radius, max_color)
	for p in _minima:
		var local_p: Vector2 = axes.c2p(p.x, p.y)
		draw_circle(local_p, marker_radius, min_color)
