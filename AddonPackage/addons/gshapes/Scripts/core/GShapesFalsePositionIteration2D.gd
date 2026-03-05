class_name GShapesFalsePositionIteration2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var left_x: float = -2.0
var right_x: float = 3.0
var iteration_count: int = 6
var zero_epsilon: float = 0.00001
var endpoint_color: Color = Color(0.42, 0.9, 1.0, 0.92)
var estimate_color: Color = Color(1.0, 0.72, 0.34, 0.95)
var chord_color: Color = Color(1.0, 0.88, 0.55, 0.88)
var line_width: float = 2.0
var point_radius: float = 3.8
var show_labels: bool = true
var auto_update: bool = true

var _a_points: Array[Vector2] = []
var _b_points: Array[Vector2] = []
var _c_points: Array[Vector2] = []
var _chords: Array[PackedVector2Array] = []
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
	_c_points.clear()
	_chords.clear()
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
		if absf(fb - fa) <= 0.0000001:
			break
		var c: float = (a * fb - b * fa) / (fb - fa)
		var fc: float = _eval_y(c)

		_a_points.append(Vector2(a, fa))
		_b_points.append(Vector2(b, fb))
		_c_points.append(Vector2(c, fc))
		_chords.append(PackedVector2Array([
			axes.c2p(a, fa),
			axes.c2p(b, fb),
		]))

		if absf(fc) <= zero_epsilon:
			break
		if fa * fc <= 0.0:
			b = c
			fb = fc
		else:
			a = c
			fa = fc

	_update_labels()
	queue_redraw()


func current_estimate() -> float:
	if _c_points.is_empty():
		return 0.5 * (left_x + right_x)
	return _c_points[_c_points.size() - 1].x


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
	if not show_labels or _label_layer == null or axes == null or _c_points.is_empty():
		return
	var c: Vector2 = _c_points[_c_points.size() - 1]
	var l: Label = Label.new()
	l.text = "false_pos=%.4f" % c.x
	l.add_theme_font_size_override("font_size", 13)
	l.modulate = estimate_color
	l.position = axes.c2p(c.x, c.y) + Vector2(8.0, -20.0)
	_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return

	for seg in _chords:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], chord_color, line_width)

	for p in _a_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, endpoint_color)
	for p in _b_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, endpoint_color)
	for p in _c_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, estimate_color)



