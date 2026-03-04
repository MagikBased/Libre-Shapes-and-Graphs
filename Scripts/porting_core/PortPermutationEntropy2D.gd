class_name PortPermutationEntropy2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var settle_iterations: int = 120
var sample_count: int = 720
var min_dimension: int = 2
var max_dimension: int = 7
var embedding_delay: int = 1
var bar_width_scale: float = 0.82
var alpha: float = 0.9
var auto_update: bool = true

var _dimensions: Array[int] = []
var _entropy_values: Array[float] = []
var _bar_width: float = 1.0
var _peak_entropy: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_dimensions.clear()
	_entropy_values.clear()
	_peak_entropy = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(64, sample_count)
	var tau: int = maxi(1, embedding_delay)
	var d_min: int = maxi(2, min_dimension)
	var d_max: int = maxi(d_min, max_dimension)

	var seq: Array[float] = []
	seq.resize(n)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		seq[i] = x

	var count_dims: int = d_max - d_min + 1
	_dimensions.resize(count_dims)
	_entropy_values.resize(count_dims)
	for d in range(d_min, d_max + 1):
		var windows: int = n - (d - 1) * tau
		if windows <= 0:
			continue

		var counts: Dictionary = {}
		for i in range(windows):
			var values: Array[float] = []
			values.resize(d)
			for j in range(d):
				values[j] = seq[i + j * tau]
			var pattern: String = _ordinal_pattern(values)
			counts[pattern] = int(counts.get(pattern, 0)) + 1

		var h: float = 0.0
		for c in counts.values():
			var p: float = float(c) / float(windows)
			if p > 0.0:
				h -= p * (log(p) / log(2.0))

		# Normalize by maximal entropy log2(d!)
		var hmax: float = log(float(_factorial(d))) / log(2.0)
		var hnorm: float = 0.0
		if hmax > 0.0:
			hnorm = h / hmax

		var idx: int = d - d_min
		_dimensions[idx] = d
		_entropy_values[idx] = clampf(hnorm, 0.0, 1.0)
		_peak_entropy = maxf(_peak_entropy, _entropy_values[idx])

	var p0: Vector2 = axes.c2p(float(d_min), 0.0)
	var p1: Vector2 = axes.c2p(float(d_min + 1), 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func dimension_count() -> int:
	return _dimensions.size()


func peak_entropy() -> float:
	return _peak_entropy


func _map_value(xv: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(xv, parameter)
		if v is float or v is int:
			return float(v)
	return xv


func _ordinal_pattern(values: Array[float]) -> String:
	var pairs: Array[Vector2] = []
	for i in range(values.size()):
		pairs.append(Vector2(values[i], float(i)))
	pairs.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		if a.x == b.x:
			return a.y < b.y
		return a.x < b.x
	)
	var out: PackedStringArray = PackedStringArray()
	for p in pairs:
		out.append(str(int(p.y)))
	return ",".join(out)


func _factorial(n: int) -> int:
	var acc: int = 1
	for i in range(2, n + 1):
		acc *= i
	return acc


func _color_for_entropy(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.80, 0.36, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_dimensions.size()):
		var d: float = float(_dimensions[i])
		var h: float = _entropy_values[i]
		var p0: Vector2 = axes.c2p(d, 0.0)
		var p1: Vector2 = axes.c2p(d, h)
		draw_line(p0, p1, _color_for_entropy(h), _bar_width)
