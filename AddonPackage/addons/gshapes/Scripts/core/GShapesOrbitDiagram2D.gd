class_name GShapesOrbitDiagram2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_min: float = 2.5
var parameter_max: float = 4.0
var parameter_samples: int = 220
var initial_value: float = 0.5
var settle_iterations: int = 80
var sample_iterations: int = 36
var point_radius: float = 1.2
var point_color: Color = Color(1.0, 0.86, 0.4, 0.9)
var auto_update: bool = true

var _points: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_points.clear()
	if axes == null:
		queue_redraw()
		return

	var p_min: float = minf(parameter_min, parameter_max)
	var p_max: float = maxf(parameter_min, parameter_max)
	var p_count: int = maxi(2, parameter_samples)
	var settle: int = maxi(0, settle_iterations)
	var keep: int = maxi(1, sample_iterations)

	var out: Array[Vector2] = []
	for i in range(p_count):
		var t: float = float(i) / float(p_count - 1)
		var p: float = lerpf(p_min, p_max, t)
		var x: float = initial_value

		for _s in range(settle):
			x = _map_value(x, p)

		for _k in range(keep):
			x = _map_value(x, p)
			out.append(axes.c2p(p, x))

	_points = PackedVector2Array(out)
	queue_redraw()


func point_count() -> int:
	return _points.size()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _draw() -> void:
	for i in range(_points.size()):
		draw_circle(_points[i], point_radius, point_color)



