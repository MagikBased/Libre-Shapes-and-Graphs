class_name LsgSecantIteration2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var function_callable: Callable
var x0: float = 0.0
var x1: float = 1.0
var iteration_count: int = 6
var denominator_epsilon: float = 0.0000001
var estimate_color: Color = Color(1.0, 0.74, 0.34, 0.95)
var chord_color: Color = Color(1.0, 0.9, 0.55, 0.88)
var point_color: Color = Color(0.42, 0.9, 1.0, 0.92)
var line_width: float = 2.0
var point_radius: float = 3.8
var show_labels: bool = true
var auto_update: bool = true

var _iter_points: Array[Vector2] = []
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
	_iter_points.clear()
	_chords.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	var xa: float = x0
	var xb: float = x1
	var fa: float = _eval_y(xa)
	var fb: float = _eval_y(xb)
	_iter_points.append(Vector2(xa, fa))
	_iter_points.append(Vector2(xb, fb))

	for _i in range(maxi(0, iteration_count)):
		var denom: float = fb - fa
		if absf(denom) <= denominator_epsilon:
			break
		var xc: float = xb - fb * (xb - xa) / denom
		var fc: float = _eval_y(xc)

		_chords.append(PackedVector2Array([
			axes.c2p(xa, fa),
			axes.c2p(xb, fb),
		]))
		_iter_points.append(Vector2(xc, fc))

		xa = xb
		fa = fb
		xb = xc
		fb = fc

	_update_labels()
	queue_redraw()


func current_estimate() -> float:
	if _iter_points.is_empty():
		return x1
	return _iter_points[_iter_points.size() - 1].x


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
	if not show_labels or _label_layer == null or axes == null or _iter_points.is_empty():
		return
	var p: Vector2 = _iter_points[_iter_points.size() - 1]
	var l: Label = Label.new()
	l.text = "secant=%.4f" % p.x
	l.add_theme_font_size_override("font_size", 13)
	l.modulate = estimate_color
	l.position = axes.c2p(p.x, p.y) + Vector2(8.0, -20.0)
	_label_layer.add_child(l)


func _draw() -> void:
	if axes == null:
		return
	for seg in _chords:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], chord_color, line_width)

	for i in range(_iter_points.size()):
		var p: Vector2 = _iter_points[i]
		var color_to_use: Color = estimate_color if i == _iter_points.size() - 1 else point_color
		draw_circle(axes.c2p(p.x, p.y), point_radius, color_to_use)
