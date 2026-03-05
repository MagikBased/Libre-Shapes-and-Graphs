class_name GShapesInvariantDensity2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.72
var initial_value: float = 0.23
var settle_iterations: int = 220
var sample_iterations: int = 5200
var bin_count: int = 110
var normalize_to_peak: bool = true
var density_scale: float = 1.0
var alpha: float = 0.9
var auto_update: bool = true

var _bin_centers: Array[float] = []
var _bin_values: Array[float] = []
var _line_width: float = 1.0
var _peak_density: float = 0.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_bin_centers.clear()
	_bin_values.clear()
	_peak_density = 0.0
	if axes == null:
		queue_redraw()
		return

	var bins: int = maxi(2, bin_count)
	var counts: Array[int] = []
	counts.resize(bins)
	for i in range(bins):
		counts[i] = 0

	var xmin: float = minf(axes.x_min, axes.x_max)
	var xmax: float = maxf(axes.x_min, axes.x_max)
	var width: float = maxf(0.000001, xmax - xmin)
	var bin_width: float = width / float(bins)

	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)

	var kept: int = 0
	for _k in range(maxi(1, sample_iterations)):
		x = _map_value(x, parameter_value)
		if x < xmin or x > xmax:
			continue
		var t: float = (x - xmin) / width
		var idx: int = clampi(int(floor(t * float(bins))), 0, bins - 1)
		counts[idx] += 1
		kept += 1

	var peak_count: int = 0
	for c in counts:
		peak_count = maxi(peak_count, c)

	_bin_centers.resize(bins)
	_bin_values.resize(bins)
	for i in range(bins):
		var xc: float = xmin + (float(i) + 0.5) * bin_width
		_bin_centers[i] = xc

		var value: float = 0.0
		if normalize_to_peak:
			if peak_count > 0:
				value = float(counts[i]) / float(peak_count)
		else:
			if kept > 0:
				value = float(counts[i]) / (float(kept) * bin_width)
		value *= density_scale
		_bin_values[i] = value
		_peak_density = maxf(_peak_density, value)

	# Match line thickness to bin spacing in axes space.
	var px0: Vector2 = axes.c2p(xmin, 0.0)
	var px1: Vector2 = axes.c2p(xmin + bin_width, 0.0)
	_line_width = maxf(1.0, absf(px1.x - px0.x) * 0.82)

	queue_redraw()


func bar_count() -> int:
	return _bin_values.size()


func peak_density() -> float:
	return _peak_density


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _color_for_density(v: float) -> Color:
	var t: float = clampf(v, 0.0, 1.0)
	var c0: Color = Color(0.34, 0.84, 1.0, alpha)
	var c1: Color = Color(1.0, 0.78, 0.35, alpha)
	return c0.lerp(c1, t)


func _draw() -> void:
	for i in range(_bin_values.size()):
		var x: float = _bin_centers[i]
		var y: float = _bin_values[i]
		var p0: Vector2 = axes.c2p(x, 0.0)
		var p1: Vector2 = axes.c2p(x, y)
		draw_line(p0, p1, _color_for_density(y), _line_width)



