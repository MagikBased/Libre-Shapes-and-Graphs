class_name LsgPowerSpectrum2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.82
var initial_value: float = 0.23
var settle_iterations: int = 120
var sample_count: int = 256
var max_bins: int = 96
var use_hann_window: bool = true
var bar_width_scale: float = 0.9
var alpha: float = 0.9
var auto_update: bool = true

var _freqs: Array[float] = []
var _powers: Array[float] = []
var _bar_width: float = 1.0
var _peak_power: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_freqs.clear()
	_powers.clear()
	_peak_power = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(32, sample_count)
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

	# Remove DC offset and optionally apply Hann taper.
	var windowed: Array[float] = []
	windowed.resize(n)
	for i in range(n):
		var w: float = 1.0
		if use_hann_window:
			w = 0.5 * (1.0 - cos((2.0 * PI * float(i)) / float(n - 1)))
		windowed[i] = (seq[i] - mean) * w

	var half: int = int(floor(float(n) * 0.5))
	var bins: int = mini(maxi(2, max_bins), half)
	_freqs.resize(bins)
	_powers.resize(bins)

	for k in range(bins):
		var re: float = 0.0
		var im: float = 0.0
		for t in range(n):
			var angle: float = -2.0 * PI * float(k * t) / float(n)
			var s: float = windowed[t]
			re += s * cos(angle)
			im += s * sin(angle)
		var p: float = (re * re + im * im) / float(n)
		_freqs[k] = float(k) / float(n)
		_powers[k] = p
		_peak_power = maxf(_peak_power, p)

	if _peak_power > 0.0:
		for i in range(_powers.size()):
			_powers[i] /= _peak_power

	var p0: Vector2 = axes.c2p(0.0, 0.0)
	var p1: Vector2 = axes.c2p(1.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func bin_count() -> int:
	return _powers.size()


func peak_power() -> float:
	return _peak_power


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_power(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_powers.size()):
		var f: float = _freqs[i]
		var p: float = _powers[i]
		var p0: Vector2 = axes.c2p(f, 0.0)
		var p1: Vector2 = axes.c2p(f, p)
		draw_line(p0, p1, _color_for_power(p), _bar_width)
