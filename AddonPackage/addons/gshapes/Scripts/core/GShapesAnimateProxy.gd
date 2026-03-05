class_name GShapesAnimateProxy
extends RefCounted

var _builder: GShapesAnimationBuilder


func _init(target: Node2D) -> void:
	_builder = GShapesAnimationBuilder.new(target)


func set_run_time(seconds: float) -> GShapesAnimationBuilder:
	return _builder.set_run_time(seconds)


func set_rate_func(name: StringName) -> GShapesAnimationBuilder:
	return _builder.set_rate_func(name)


func move_to(pos: Vector2) -> GShapesAnimationBuilder:
	return _builder.move_to(pos)


func set_position(pos: Vector2) -> GShapesAnimationBuilder:
	return _builder.set_position(pos)


func shift(delta: Vector2) -> GShapesAnimationBuilder:
	return _builder.shift(delta)


func scale_to(new_scale: Variant) -> GShapesAnimationBuilder:
	return _builder.scale_to(new_scale)


func rotate_to(rotation_radians: float) -> GShapesAnimationBuilder:
	return _builder.rotate_to(rotation_radians)


func set_color(new_color: Color) -> GShapesAnimationBuilder:
	return _builder.set_color(new_color)


func set_modulate(new_modulate: Color) -> GShapesAnimationBuilder:
	return _builder.set_modulate(new_modulate)


func set_opacity(opacity: float) -> GShapesAnimationBuilder:
	return _builder.set_opacity(opacity)


func set_value(new_value: float) -> GShapesAnimationBuilder:
	return _builder.set_value(new_value)




