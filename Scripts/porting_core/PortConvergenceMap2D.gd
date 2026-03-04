class_name PortConvergenceMap2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.2
var seed_min: float = 0.0
var seed_max: float = 1.0
var seed_samples: int = 260
var iteration_count: int = 80
var point_radius: float = 1.2
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

	var a: float = minf(seed_min, seed_max)
	var b: float = maxf(seed_min, seed_max)
	var n: int = maxi(2, seed_samples)
	var steps: int = maxi(1, iteration_count)

	for i in range(n):
		var t: float = float(i) / float(n - 1)
		var seed_value: float = lerpf(a, b, t)
		var x: float = seed_value
		for _k in range(steps):
			x = _map_value(x, parameter_value)

		var local: Vector2 = axes.c2p(seed_value, x)
		_points.append(local)
		_colors.append(_color_for_value(x))

	queue_redraw()


func point_count() -> int:
	return _points.size()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_value(v: float) -> Color:
	var t: float = clampf((v - axes.y_min) / maxf(0.0001, axes.y_max - axes.y_min), 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.76, 0.34, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_points.size()):
		draw_circle(_points[i], point_radius, _colors[i])
