class_name PortFirstReturnTime2D
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
var bar_width_scale: float = 0.84
var alpha: float = 0.9
var auto_update: bool = true

var _times: Array[int] = []
var _counts: Array[int] = []
var _norm_counts: Array[float] = []
var _bar_width: float = 1.0
var _peak_count: int = 0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_times.clear()
	_counts.clear()
	_norm_counts.clear()
	_peak_count = 0
	if axes == null:
		queue_redraw()
		return

	var s_count: int = maxi(4, seed_samples)
	var a: float = minf(seed_min, seed_max)
	var b: float = maxf(seed_min, seed_max)
	var tmin: float = minf(target_min, target_max)
	var tmax: float = maxf(target_min, target_max)
	var kmax: int = maxi(1, max_iterations)

	_counts.resize(kmax + 1)
	for i in range(_counts.size()):
		_counts[i] = 0

	for i in range(s_count):
		var t: float = float(i) / float(s_count - 1)
		var x: float = lerpf(a, b, t)
		var hit: int = 0
		for k in range(1, kmax + 1):
			x = _map_value(x, parameter_value)
			if x >= tmin and x <= tmax:
				hit = k
				break
		_counts[hit] += 1

	for c in _counts:
		_peak_count = maxi(_peak_count, c)

	_times.resize(_counts.size())
	_norm_counts.resize(_counts.size())
	for i in range(_counts.size()):
		_times[i] = i
		if _peak_count > 0:
			_norm_counts[i] = float(_counts[i]) / float(_peak_count)
		else:
			_norm_counts[i] = 0.0

	var p0: Vector2 = axes.c2p(0.0, 0.0)
	var p1: Vector2 = axes.c2p(1.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func bin_count() -> int:
	return _times.size()


func peak_count() -> int:
	return _peak_count


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _color_for_count(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_times.size()):
		var tt: float = float(_times[i])
		var c: float = _norm_counts[i]
		var p0: Vector2 = axes.c2p(tt, 0.0)
		var p1: Vector2 = axes.c2p(tt, c)
		draw_line(p0, p1, _color_for_count(c), _bar_width)
