class_name LsgRecurrenceRateCurve2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var settle_iterations: int = 120
var sequence_length: int = 160
var threshold_min: float = 0.001
var threshold_max: float = 0.08
var threshold_samples: int = 72
var stroke_width: float = 2.0
var auto_update: bool = true

var _points: PackedVector2Array = PackedVector2Array()
var _peak_rate: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_points.clear()
	_peak_rate = 0.0
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(4, sequence_length)
	var eps_count: int = maxi(2, threshold_samples)
	var e0: float = maxf(0.0, minf(threshold_min, threshold_max))
	var e1: float = maxf(0.0, maxf(threshold_min, threshold_max))

	var seq: Array[float] = []
	seq.resize(n)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)
	for i in range(n):
		x = _map_value(x, parameter_value)
		seq[i] = x

	var total_pairs: int = n * n
	var out: Array[Vector2] = []
	for i in range(eps_count):
		var t: float = float(i) / float(eps_count - 1)
		var eps: float = lerpf(e0, e1, t)

		var hits: int = 0
		for a in range(n):
			for b in range(n):
				if absf(seq[a] - seq[b]) <= eps:
					hits += 1

		var rr: float = float(hits) / float(total_pairs)
		_peak_rate = maxf(_peak_rate, rr)
		out.append(axes.c2p(eps, rr))

	_points = PackedVector2Array(out)
	queue_redraw()


func sample_count() -> int:
	return _points.size()


func peak_rate() -> float:
	return _peak_rate


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
