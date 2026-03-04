class_name PortBlockEntropy2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var partition_value: float = 0.5
var settle_iterations: int = 120
var symbol_count: int = 520
var max_block_length: int = 10
var bar_width_scale: float = 0.82
var alpha: float = 0.9
var auto_update: bool = true

var _block_lengths: Array[int] = []
var _entropies: Array[float] = []
var _bar_width: float = 1.0
var _peak_entropy: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_block_lengths.clear()
	_entropies.clear()
	_peak_entropy = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(16, symbol_count)
	var k_max: int = mini(maxi(1, max_block_length), n - 1)
	var symbols: Array[int] = []
	symbols.resize(n)

	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		symbols[i] = 1 if x >= partition_value else 0

	_block_lengths.resize(k_max)
	_entropies.resize(k_max)
	for k in range(1, k_max + 1):
		var counts: Dictionary = {}
		var window_count: int = n - k + 1
		for i in range(window_count):
			var word: String = ""
			for j in range(k):
				word += "1" if symbols[i + j] == 1 else "0"
			counts[word] = int(counts.get(word, 0)) + 1

		var entropy_bits: float = 0.0
		for c in counts.values():
			var p: float = float(c) / float(window_count)
			if p > 0.0:
				entropy_bits -= p * (log(p) / log(2.0))

		_block_lengths[k - 1] = k
		_entropies[k - 1] = entropy_bits
		_peak_entropy = maxf(_peak_entropy, entropy_bits)

	var p0: Vector2 = axes.c2p(1.0, 0.0)
	var p1: Vector2 = axes.c2p(2.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func block_count() -> int:
	return _block_lengths.size()


func peak_entropy() -> float:
	return _peak_entropy


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_entropy(v: float) -> Color:
	var denom: float = maxf(0.0001, float(max_block_length))
	var t: float = clampf(v / denom, 0.0, 1.0)
	var c0: Color = Color(0.35, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_block_lengths.size()):
		var k: float = float(_block_lengths[i])
		var h: float = _entropies[i]
		var p0: Vector2 = axes.c2p(k, 0.0)
		var p1: Vector2 = axes.c2p(k, h)
		draw_line(p0, p1, _color_for_entropy(h), _bar_width)
