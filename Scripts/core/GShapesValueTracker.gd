class_name GShapesValueTracker
extends Node2D

var animate: GShapesAnimateProxy:
	get:
		return GShapesAnimateProxy.new(self)

var value: float = 0.0


func _init(initial_value: float = 0.0) -> void:
	value = initial_value


func set_value(new_value: float) -> void:
	value = new_value


func get_value() -> float:
	return value




