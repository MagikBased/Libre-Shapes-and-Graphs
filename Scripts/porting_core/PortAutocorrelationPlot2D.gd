class_name PortAutocorrelationPlot2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.82
var initial_value: float = 0.23
var settle_iterations: int = 120
var sample_count: int = 360
var max_lag: int = 120
var bar_width_scale: float = 0.84
var alpha: float = 0.9
var auto_update: bool = true

var _lags: Array[int] = []
var _values: Array[float] = []
var _bar_width: float = 1.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_lags.clear()
	_values.clear()
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(8, sample_count)
	var lag_cap: int = mini(maxi(1, max_lag), n - 2)

	var seq: Array[float] = []
	seq.resize(n)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		seq[i] = x

	var mean: float = 0.0
	for v in seq:
		mean += v
	mean /= float(n)

	var var_sum: float = 0.0
	for v in seq:
		var d: float = v - mean
		var_sum += d * d
	var variance: float = var_sum / float(n)
	if variance <= 0.0000001:
		queue_redraw()
		return

	_lags.resize(lag_cap + 1)
	_values.resize(lag_cap + 1)
	for lag in range(lag_cap + 1):
		var cov: float = 0.0
		var count: int = n - lag
		for i in range(count):
			cov += (seq[i] - mean) * (seq[i + lag] - mean)
		cov /= float(count)
		_lags[lag] = lag
		_values[lag] = cov / variance

	var p0: Vector2 = axes.c2p(0.0, 0.0)
	var p1: Vector2 = axes.c2p(1.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func lag_count() -> int:
	return _lags.size()


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_value(v: float) -> Color:
	var t: float = 0.5 + 0.5 * clampf(v, -1.0, 1.0)
	var c0: Color = Color(0.33, 0.82, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_lags.size()):
		var lag: float = float(_lags[i])
		var val: float = _values[i]
		var p0: Vector2 = axes.c2p(lag, 0.0)
		var p1: Vector2 = axes.c2p(lag, val)
		draw_line(p0, p1, _color_for_value(val), _bar_width)
