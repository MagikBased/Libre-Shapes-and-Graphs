class_name LsgReturnMap2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.6
var initial_value: float = 0.31
var settle_iterations: int = 40
var sample_iterations: int = 180
var point_radius: float = 1.3
var alpha: float = 0.9
var auto_update: bool = true

var _points: Array[Vector2] = []
var _colors: Array[Color] = []


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_points.clear()
	_colors.clear()
	if axes == null:
		queue_redraw()
		return

	var settle: int = maxi(0, settle_iterations)
	var count: int = maxi(1, sample_iterations)
	var x_prev: float = initial_value
	for _s in range(settle):
		x_prev = _map_value(x_prev, parameter_value)

	for _i in range(count):
		var x_next: float = _map_value(x_prev, parameter_value)
		var local: Vector2 = axes.c2p(x_prev, x_next)
		_points.append(local)
		_colors.append(_color_for_pair(x_prev, x_next))
		x_prev = x_next

	queue_redraw()


func point_count() -> int:
	return _points.size()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_pair(x_prev: float, x_next: float) -> Color:
	var nx: float = clampf((x_prev - axes.x_min) / maxf(0.0001, axes.x_max - axes.x_min), 0.0, 1.0)
	var ny: float = clampf((x_next - axes.y_min) / maxf(0.0001, axes.y_max - axes.y_min), 0.0, 1.0)
	var t: float = clampf(0.5 * (nx + ny), 0.0, 1.0)
	var c0: Color = Color(0.38, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.82, 0.4, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_points.size()):
		draw_circle(_points[i], point_radius, _colors[i])
