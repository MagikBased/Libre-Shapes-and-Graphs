class_name LsgReturnTimeQuantiles2D
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
var quantiles: Array[float] = [0.1, 0.25, 0.5, 0.75, 0.9]
var bar_width_scale: float = 0.78
var alpha: float = 0.9
var auto_update: bool = true

var _q_positions: Array[float] = []
var _q_values: Array[float] = []
var _bar_width: float = 1.0
var _max_value: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_q_positions.clear()
	_q_values.clear()
	_max_value = 0.0
	if axes == null:
		queue_redraw()
		return

	var s_count: int = maxi(8, seed_samples)
	var a: float = minf(seed_min, seed_max)
	var b: float = maxf(seed_min, seed_max)
	var tmin: float = minf(target_min, target_max)
	var tmax: float = maxf(target_min, target_max)
	var kmax: int = maxi(1, max_iterations)

	var samples: Array[float] = []
	for i in range(s_count):
		var t: float = float(i) / float(s_count - 1)
		var x: float = lerpf(a, b, t)
		var hit: int = 0
		for k in range(1, kmax + 1):
			x = _map_value(x, parameter_value)
			if x >= tmin and x <= tmax:
				hit = k
				break
		var value: float = float(kmax + 1) if hit == 0 else float(hit)
		samples.append(value)

	samples.sort()
	var q_src: Array[float] = []
	for qv in quantiles:
		q_src.append(clampf(float(qv), 0.0, 1.0))
	if q_src.is_empty():
		q_src = [0.5]

	_q_positions.resize(q_src.size())
	_q_values.resize(q_src.size())
	for i in range(q_src.size()):
		var q: float = q_src[i]
		var idx: int = int(round(q * float(samples.size() - 1)))
		idx = clampi(idx, 0, samples.size() - 1)
		var v: float = samples[idx]
		_q_positions[i] = float(i + 1)
		_q_values[i] = v
		_max_value = maxf(_max_value, v)

	if _max_value > 0.0:
		for i in range(_q_values.size()):
			_q_values[i] /= _max_value

	var p0: Vector2 = axes.c2p(1.0, 0.0)
	var p1: Vector2 = axes.c2p(2.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func quantile_count() -> int:
	return _q_positions.size()


func max_raw_value() -> float:
	return _max_value


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _color_for_value(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_q_positions.size()):
		var x: float = _q_positions[i]
		var y: float = _q_values[i]
		var p0: Vector2 = axes.c2p(x, 0.0)
		var p1: Vector2 = axes.c2p(x, y)
		draw_line(p0, p1, _color_for_value(y), _bar_width)
