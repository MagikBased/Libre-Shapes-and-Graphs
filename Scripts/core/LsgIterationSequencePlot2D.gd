class_name LsgIterationSequencePlot2D
extends LsgPolylineMobject

var axes: GraphAxes2D
var map_callable: Callable
var initial_value: float = 0.5
var iteration_count: int = 10
var include_initial: bool = true
var auto_update: bool = true

var _values: Array[float] = []


func _ready() -> void:
	rebuild_sequence()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild_sequence()


func rebuild_sequence() -> void:
	_values.clear()
	if axes == null:
		points = PackedVector2Array()
		queue_redraw()
		return

	var x_n: float = initial_value
	if include_initial:
		_values.append(x_n)

	for _i in range(maxi(0, iteration_count)):
		x_n = _map_value(x_n)
		_values.append(x_n)

	var out: PackedVector2Array = PackedVector2Array()
	out.resize(_values.size())
	for i in range(_values.size()):
		out[i] = axes.c2p(float(i), _values[i])

	points = out
	queue_redraw()


func sequence_values() -> Array[float]:
	return _values.duplicate()


func latest_value() -> float:
	if _values.is_empty():
		return initial_value
	return _values[_values.size() - 1]


func _map_value(x: float) -> float:
	if map_callable.is_valid():
		var v: Variant = map_callable.call(x)
		if v is float or v is int:
			return float(v)
	return x
