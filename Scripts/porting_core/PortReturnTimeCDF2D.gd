class_name PortReturnTimeCDF2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var seed_min: float = 0.0
var seed_max: float = 1.0
var seed_samples: int = 260
var target_min: float = 0.45
var target_max: float = 0.55
var max_iterations: int = 180
var stroke_width: float = 2.0
var auto_update: bool = true

var _points: PackedVector2Array = PackedVector2Array()
var _hit_fraction: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_points.clear()
	_hit_fraction = 0.0
	if axes == null:
		queue_redraw()
		return

	var s_count: int = maxi(4, seed_samples)
	var a: float = minf(seed_min, seed_max)
	var b: float = maxf(seed_min, seed_max)
	var tmin: float = minf(target_min, target_max)
	var tmax: float = maxf(target_min, target_max)
	var kmax: int = maxi(1, max_iterations)

	var hit_times: Array[int] = []
	hit_times.resize(s_count)
	for i in range(s_count):
		var t: float = float(i) / float(s_count - 1)
		var x: float = lerpf(a, b, t)
		var hit: int = 0
		for k in range(1, kmax + 1):
			x = _map_value(x, parameter_value)
			if x >= tmin and x <= tmax:
				hit = k
				break
		hit_times[i] = hit

	var cumulative: Array[int] = []
	cumulative.resize(kmax + 1)
	for i in range(cumulative.size()):
		cumulative[i] = 0

	var hit_total: int = 0
	for ht in hit_times:
		if ht > 0:
			hit_total += 1
			cumulative[ht] += 1
	_hit_fraction = float(hit_total) / float(s_count)

	for k in range(1, cumulative.size()):
		cumulative[k] += cumulative[k - 1]

	var out: Array[Vector2] = []
	out.append(axes.c2p(0.0, 0.0))
	for k in range(1, cumulative.size()):
		var cdf: float = float(cumulative[k]) / float(s_count)
		out.append(axes.c2p(float(k), cdf))

	_points = PackedVector2Array(out)
	queue_redraw()


func point_count() -> int:
	return _points.size()


func hit_fraction() -> float:
	return _hit_fraction


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _draw() -> void:
	if _points.size() < 2:
		return
	for i in range(_points.size() - 1):
		var t: float = float(i) / float(maxi(1, _points.size() - 1))
		var c: Color = Color(0.34, 0.84, 1.0, 0.9).lerp(Color(1.0, 0.8, 0.36, 0.95), t)
		draw_line(_points[i], _points[i + 1], c, stroke_width)
