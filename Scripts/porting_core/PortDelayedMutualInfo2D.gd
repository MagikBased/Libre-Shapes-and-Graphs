class_name PortDelayedMutualInfo2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var settle_iterations: int = 120
var sample_count: int = 520
var max_delay: int = 80
var histogram_bins: int = 24
var bar_width_scale: float = 0.86
var alpha: float = 0.9
var auto_update: bool = true

var _delays: Array[int] = []
var _mi_values: Array[float] = []
var _bar_width: float = 1.0
var _peak_mi: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_delays.clear()
	_mi_values.clear()
	_peak_mi = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(64, sample_count)
	var tau_max: int = mini(maxi(1, max_delay), n - 2)
	var bins: int = maxi(4, histogram_bins)

	var seq: Array[float] = []
	seq.resize(n)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		seq[i] = x

	var xmin: float = seq[0]
	var xmax: float = seq[0]
	for v in seq:
		xmin = minf(xmin, v)
		xmax = maxf(xmax, v)
	var width: float = maxf(0.000001, xmax - xmin)

	_delays.resize(tau_max + 1)
	_mi_values.resize(tau_max + 1)
	for tau in range(tau_max + 1):
		var pair_count: int = n - tau
		var px: Array[int] = []
		var py: Array[int] = []
		px.resize(bins)
		py.resize(bins)
		var pxy: Dictionary = {}

		for i in range(pair_count):
			var xi: float = seq[i]
			var yi: float = seq[i + tau]
			var bx: int = clampi(int(floor(((xi - xmin) / width) * float(bins))), 0, bins - 1)
			var by: int = clampi(int(floor(((yi - xmin) / width) * float(bins))), 0, bins - 1)
			px[bx] += 1
			py[by] += 1
			var key: String = "%d:%d" % [bx, by]
			pxy[key] = int(pxy.get(key, 0)) + 1

		var mi: float = 0.0
		for key in pxy.keys():
			var parts: PackedStringArray = String(key).split(":")
			var bx_idx: int = int(parts[0])
			var by_idx: int = int(parts[1])
			var pxy_v: float = float(pxy[key]) / float(pair_count)
			var px_v: float = float(px[bx_idx]) / float(pair_count)
			var py_v: float = float(py[by_idx]) / float(pair_count)
			if pxy_v > 0.0 and px_v > 0.0 and py_v > 0.0:
				mi += pxy_v * (log(pxy_v / (px_v * py_v)) / log(2.0))

		_delays[tau] = tau
		_mi_values[tau] = mi
		_peak_mi = maxf(_peak_mi, mi)

	var p0: Vector2 = axes.c2p(0.0, 0.0)
	var p1: Vector2 = axes.c2p(1.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func delay_count() -> int:
	return _delays.size()


func peak_mi() -> float:
	return _peak_mi


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _color_for_mi(v: float) -> Color:
	var t: float = clampf(v / maxf(0.0001, _peak_mi), 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_delays.size()):
		var d: float = float(_delays[i])
		var mi: float = _mi_values[i]
		var p0: Vector2 = axes.c2p(d, 0.0)
		var p1: Vector2 = axes.c2p(d, mi)
		draw_line(p0, p1, _color_for_mi(mi), _bar_width)
