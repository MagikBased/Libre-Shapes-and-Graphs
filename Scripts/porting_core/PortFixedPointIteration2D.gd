class_name PortFixedPointIteration2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var initial_x: float = 0.5
var iteration_count: int = 8
var map_color: Color = Color(0.36, 0.88, 1.0, 0.92)
var diag_color: Color = Color(1.0, 0.72, 0.34, 0.9)
var step_color: Color = Color(1.0, 0.9, 0.58, 0.92)
var point_color: Color = Color(1.0, 0.84, 0.35, 0.96)
var line_width: float = 2.0
var point_radius: float = 3.6
var map_samples: int = 220
var auto_update: bool = true
var show_labels: bool = true

var _map_polyline: PackedVector2Array = PackedVector2Array()
var _iter_points: Array[Vector2] = []
var _steps: Array[PackedVector2Array] = []
var _label_layer: Node2D


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_map_polyline.clear()
	_iter_points.clear()
	_steps.clear()
	if axes == null:
		_clear_labels()
		queue_redraw()
		return

	_rebuild_map_polyline()
	_rebuild_iteration_steps()
	_update_labels()
	queue_redraw()


func current_estimate() -> float:
	if _iter_points.is_empty():
		return initial_x
	return _iter_points[_iter_points.size() - 1].x


func _map_value(x: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x)
		if v is float or v is int:
			return float(v)
	return x


func _rebuild_map_polyline() -> void:
	var n: int = maxi(2, map_samples)
	var left: float = axes.x_min
	var right: float = axes.x_max
	for i in range(n):
		var t: float = float(i) / float(n - 1)
		var x: float = lerpf(left, right, t)
		var y: float = _map_value(x)
		_map_polyline.append(axes.c2p(x, y))


func _rebuild_iteration_steps() -> void:
	var x_n: float = initial_x
	var max_iter: int = maxi(0, iteration_count)
	_iter_points.append(Vector2(x_n, _map_value(x_n)))
	for _i in range(max_iter):
		var y_n: float = _map_value(x_n)
		var p_vertical: PackedVector2Array = PackedVector2Array([
			axes.c2p(x_n, x_n),
			axes.c2p(x_n, y_n),
		])
		_steps.append(p_vertical)

		var x_next: float = y_n
		var p_horizontal: PackedVector2Array = PackedVector2Array([
			axes.c2p(x_n, y_n),
			axes.c2p(x_next, y_n),
		])
		_steps.append(p_horizontal)
		x_n = x_next
		_iter_points.append(Vector2(x_n, _map_value(x_n)))


func _clear_labels() -> void:
	if _label_layer == null:
		return
	for child in _label_layer.get_children():
		child.queue_free()


func _update_labels() -> void:
	_clear_labels()
	if not show_labels or _label_layer == null or axes == null:
		return
	if _iter_points.is_empty():
		return
	var x_est: float = current_estimate()
	var label: Label = Label.new()
	label.text = "x*=%.4f" % x_est
	label.add_theme_font_size_override("font_size", 13)
	label.modulate = point_color
	label.position = axes.c2p(x_est, x_est) + Vector2(8.0, -22.0)
	_label_layer.add_child(label)


func _draw() -> void:
	if axes == null:
		return
	# y=x diagonal
	draw_line(axes.c2p(axes.x_min, axes.x_min), axes.c2p(axes.x_max, axes.x_max), diag_color, line_width)

	for i in range(_map_polyline.size() - 1):
		draw_line(_map_polyline[i], _map_polyline[i + 1], map_color, line_width)

	for seg in _steps:
		if seg.size() >= 2:
			draw_line(seg[0], seg[1], step_color, line_width)

	for p in _iter_points:
		draw_circle(axes.c2p(p.x, p.y), point_radius, point_color)
