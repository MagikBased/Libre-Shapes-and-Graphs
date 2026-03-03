class_name PortGraphRoots2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var x_min_value: float = -6.0
var x_max_value: float = 6.0
var sample_count: int = 220
var bisection_steps: int = 22
var zero_epsilon: float = 0.0001
var merge_epsilon: float = 0.02
var max_roots: int = 32
var marker_radius: float = 4.2
var marker_color: Color = Color(0.96, 0.84, 0.34, 0.95)
var show_labels: bool = true
var auto_update: bool = true

var _roots: Array[float] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_roots.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var left: float = minf(x_min_value, x_max_value)
	var right: float = maxf(x_min_value, x_max_value)
	var n: int = maxi(4, sample_count)
	var step_x: float = (right - left) / float(n - 1)
	var x_prev: float = left
	var y_prev: float = _eval_y(x_prev)

	for i in range(1, n):
		var x_curr: float = left + float(i) * step_x
		var y_curr: float = _eval_y(x_curr)

		if absf(y_prev) <= zero_epsilon:
			_add_root(x_prev)
		if y_prev * y_curr < 0.0:
			var root: float = _bisect_root(x_prev, x_curr)
			_add_root(root)
		elif absf(y_curr) <= zero_epsilon:
			_add_root(x_curr)

		if _roots.size() >= max_roots:
			break
		x_prev = x_curr
		y_prev = y_curr

	_update_labels()
	queue_redraw()


func roots() -> Array[float]:
	return _roots.duplicate()


func _eval_y(x: float) -> float:
	if function_callable.is_valid():
		var v: Variant = function_callable.call(x)
		if v is float or v is int:
			return float(v)
	if graph != null:
		return graph.eval_y(x)
	return 0.0


func _bisect_root(a0: float, b0: float) -> float:
	var a: float = a0
	var b: float = b0
	var fa: float = _eval_y(a)
	var fb: float = _eval_y(b)
	if absf(fa) <= zero_epsilon:
		return a
	if absf(fb) <= zero_epsilon:
		return b

	for _i in range(maxi(4, bisection_steps)):
		var m: float = 0.5 * (a + b)
		var fm: float = _eval_y(m)
		if absf(fm) <= zero_epsilon:
			return m
		if fa * fm <= 0.0:
			b = m
			fb = fm
		else:
			a = m
			fa = fm
	return 0.5 * (a + b)


func _add_root(x: float) -> void:
	for r in _roots:
		if absf(r - x) <= merge_epsilon:
			return
	_roots.append(x)


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or axes == null or _label_layer == null:
		return
	for r in _roots:
		var label: Label = Label.new()
		label.text = "x=%.2f" % r
		label.add_theme_font_size_override("font_size", 13)
		label.modulate = marker_color
		var p: Vector2 = axes.c2p(r, 0.0)
		label.position = p + Vector2(6.0, -22.0)
		_label_layer.add_child(label)


func _draw() -> void:
	if axes == null:
		return
	for r in _roots:
		var p: Vector2 = axes.c2p(r, 0.0)
		draw_circle(p, marker_radius, marker_color)
		draw_line(p + Vector2(0.0, -8.0), p + Vector2(0.0, 8.0), marker_color, 1.8)
