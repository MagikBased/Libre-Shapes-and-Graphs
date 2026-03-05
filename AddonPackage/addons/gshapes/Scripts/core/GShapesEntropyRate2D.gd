class_name GShapesEntropyRate2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var partition_value: float = 0.5
var settle_iterations: int = 120
var symbol_count: int = 700
var max_block_length: int = 10
var bar_width_scale: float = 0.82
var alpha: float = 0.9
var auto_update: bool = true

var _orders: Array[int] = []
var _rates: Array[float] = []
var _bar_width: float = 1.0
var _peak_rate: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_orders.clear()
	_rates.clear()
	_peak_rate = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(24, symbol_count)
	var kmax: int = mini(maxi(2, max_block_length), n - 1)
	var symbols: Array[int] = []
	symbols.resize(n)

	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		symbols[i] = 1 if x >= partition_value else 0

	var block_entropies: Array[float] = []
	block_entropies.resize(kmax + 1)
	block_entropies[0] = 0.0
	for k in range(1, kmax + 1):
		var counts: Dictionary = {}
		var window_count: int = n - k + 1
		for i in range(window_count):
			var word: String = ""
			for j in range(k):
				word += "1" if symbols[i + j] == 1 else "0"
			counts[word] = int(counts.get(word, 0)) + 1
		var h: float = 0.0
		for c in counts.values():
			var p: float = float(c) / float(window_count)
			if p > 0.0:
				h -= p * (log(p) / log(2.0))
		block_entropies[k] = h

	_orders.resize(kmax)
	_rates.resize(kmax)
	for k in range(1, kmax + 1):
		var hk: float = block_entropies[k]
		var hk_prev: float = block_entropies[k - 1]
		var rate: float = maxf(0.0, hk - hk_prev)
		_orders[k - 1] = k
		_rates[k - 1] = rate
		_peak_rate = maxf(_peak_rate, rate)

	if _peak_rate > 0.0:
		for i in range(_rates.size()):
			_rates[i] /= _peak_rate

	var p0: Vector2 = axes.c2p(1.0, 0.0)
	var p1: Vector2 = axes.c2p(2.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func order_count() -> int:
	return _orders.size()


func peak_rate() -> float:
	return _peak_rate


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _color_for_rate(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_orders.size()):
		var k: float = float(_orders[i])
		var r: float = _rates[i]
		var p0: Vector2 = axes.c2p(k, 0.0)
		var p1: Vector2 = axes.c2p(k, r)
		draw_line(p0, p1, _color_for_rate(r), _bar_width)



