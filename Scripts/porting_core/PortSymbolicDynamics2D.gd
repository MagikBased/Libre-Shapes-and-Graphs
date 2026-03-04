class_name PortSymbolicDynamics2D
extends Node2D

var axes: GraphAxes2D
var map_callable: Callable
var parameter_value: float = 3.85
var initial_value: float = 0.23
var partition_value: float = 0.5
var settle_iterations: int = 120
var symbol_count: int = 180
var bar_width_scale: float = 0.86
var alpha: float = 0.9
var auto_update: bool = true

var _symbols: Array[int] = []
var _bar_width: float = 2.0


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_symbols.clear()
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(2, symbol_count)
	var x: float = initial_value
	for _s in range(maxi(0, settle_iterations)):
		x = _map_value(x, parameter_value)

	_symbols.resize(n)
	for i in range(n):
		x = _map_value(x, parameter_value)
		_symbols[i] = 1 if x >= partition_value else 0

	var p0: Vector2 = axes.c2p(0.0, 0.0)
	var p1: Vector2 = axes.c2p(1.0, 0.0)
	_bar_width = maxf(1.0, absf(p1.x - p0.x) * bar_width_scale)
	queue_redraw()


func symbol_total() -> int:
	return _symbols.size()


func one_count() -> int:
	var acc: int = 0
	for s in _symbols:
		if s == 1:
			acc += 1
	return acc


func _map_value(x: float, parameter: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x, parameter)
		if v is float or v is int:
			return float(v)
	return x


func _bar_color(sym: int) -> Color:
	if sym == 1:
		return Color(1.0, 0.82, 0.35, alpha)
	return Color(0.34, 0.84, 1.0, alpha)


func _draw() -> void:
	for i in range(_symbols.size()):
		var y: float = float(_symbols[i])
		var p0: Vector2 = axes.c2p(float(i), 0.0)
		var p1: Vector2 = axes.c2p(float(i), y)
		draw_line(p0, p1, _bar_color(_symbols[i]), _bar_width)
