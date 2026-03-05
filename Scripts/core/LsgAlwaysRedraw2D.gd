class_name LsgAlwaysRedraw2D
extends Node2D

var factory: Callable
var redraw_interval: float = 0.0

var _elapsed: float = 0.0
var _built_node: Node2D


func _init(p_factory: Callable = Callable(), p_redraw_interval: float = 0.0) -> void:
	factory = p_factory
	redraw_interval = maxf(0.0, p_redraw_interval)


func set_factory(new_factory: Callable) -> void:
	factory = new_factory
	refresh_now()


func set_redraw_interval(seconds: float) -> void:
	redraw_interval = maxf(0.0, seconds)


func refresh_now() -> void:
	_elapsed = 0.0
	_rebuild()


func get_built_node() -> Node2D:
	return _built_node


func _ready() -> void:
	_rebuild()


func _process(delta: float) -> void:
	if not factory.is_valid():
		return

	if is_zero_approx(redraw_interval):
		_rebuild()
		return

	_elapsed += delta
	if _elapsed >= redraw_interval:
		_rebuild()
		_elapsed = 0.0


func _rebuild() -> void:
	if not factory.is_valid():
		return

	var next_node = factory.call()
	if next_node == null or not (next_node is Node2D):
		return

	if _built_node != null and is_instance_valid(_built_node):
		_built_node.queue_free()

	_built_node = next_node as Node2D
	add_child(_built_node)
