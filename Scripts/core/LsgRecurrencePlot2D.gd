class_name LsgRecurrencePlot2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.82
var initial_value: float = 0.21
var settle_iterations: int = 120
var sequence_length: int = 140
var threshold: float = 0.006
var point_radius: float = 1.1
var alpha: float = 0.9
var auto_update: bool = true

var _sequence: Array[float] = []
var _points: Array[Vector2] = []
var _colors: Array[Color] = []


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_sequence.clear()
	_points.clear()
	_colors.clear()
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(2, sequence_length)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)

	_sequence.resize(n)
	for i in range(n):
		x = _map_value(x, parameter_value)
		_sequence[i] = x

	var eps: float = maxf(0.0, threshold)
	for i in range(n):
		for j in range(n):
			var d: float = absf(_sequence[i] - _sequence[j])
			if d <= eps:
				_points.append(axes.c2p(float(i), float(j)))
				_colors.append(_color_for_recurrence(i, j, n))

	queue_redraw()


func point_count() -> int:
	return _points.size()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_recurrence(i: int, j: int, n: int) -> Color:
	var diag: float = 1.0 - clampf(absf(float(i - j)) / maxf(1.0, float(n - 1)), 0.0, 1.0)
	var c0: Color = Color(0.36, 0.84, 1.0, alpha * 0.75)
	var c1: Color = Color(1.0, 0.82, 0.38, alpha)
	return c0.lerp(c1, diag)


func _draw() -> void:
	for i in range(_points.size()):
		draw_circle(_points[i], point_radius, _colors[i])
