class_name LsgReturnTimeMoments2D
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
var max_moment_order: int = 4
var bar_width_scale: float = 0.82
var alpha: float = 0.9
var auto_update: bool = true

var _orders: Array[int] = []
var _moments: Array[float] = []
var _peak_moment: float = 0.0
var _bar_width: float = 1.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_orders.clear()
	_moments.clear()
	_peak_moment = 0.0
	if axes == null:
		queue_redraw()
		return

	var s_count: int = maxi(8, seed_samples)
	var a: float = minf(seed_min, seed_max)
	var b: float = maxf(seed_min, seed_max)
	var tmin: float = minf(target_min, target_max)
	var tmax: float = maxf(target_min, target_max)
	var kmax: int = maxi(1, max_iterations)
	var mmax: int = maxi(1, max_moment_order)

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

	_orders.resize(mmax)
	_moments.resize(mmax)
	for order in range(1, mmax + 1):
		var acc: float = 0.0
		for ht in hit_times:
			var tval: float = float(kmax + 1) if ht == 0 else float(ht)
			acc += pow(tval, float(order))
		var moment: float = acc / float(s_count)
		_orders[order - 1] = order
		_moments[order - 1] = moment
		_peak_moment = maxf(_peak_moment, moment)

	if _peak_moment > 0.0:
		for i in range(_moments.size()):
			_moments[i] /= _peak_moment

	var p0: Vector2 = axes.c2p(1.0, 0.0)
	var p1: Vector2 = axes.c2p(2.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func order_count() -> int:
	return _orders.size()


func peak_moment() -> float:
	return _peak_moment


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
	for i in range(_orders.size()):
		var order: float = float(_orders[i])
		var val: float = _moments[i]
		var p0: Vector2 = axes.c2p(order, 0.0)
		var p1: Vector2 = axes.c2p(order, val)
		draw_line(p0, p1, _color_for_value(val), _bar_width)
