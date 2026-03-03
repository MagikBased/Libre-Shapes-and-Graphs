class_name PortObject2D
extends Node2D

var animate: PortAnimateProxy:
	get:
		return PortAnimateProxy.new(self)

var _color: Color = Color.WHITE
var color: Color:
	get:
		return _color
	set(value):
		_color = value
		queue_redraw()

var updating_suspended: bool = false
var _updaters: Array[Callable] = []


func add_updater(updater: Callable) -> void:
	# Updater signature: func updater(target: PortObject2D, delta: float) -> void
	if updater.is_valid():
		_updaters.append(updater)


func remove_updater(updater: Callable) -> void:
	var index := _updaters.find(updater)
	if index >= 0:
		_updaters.remove_at(index)


func clear_updaters() -> void:
	_updaters.clear()


func suspend_updating() -> void:
	updating_suspended = true


func resume_updating() -> void:
	updating_suspended = false


func _process(delta: float) -> void:
	if updating_suspended:
		return

	for updater in _updaters:
		if updater.is_valid():
			updater.call(self, delta)
