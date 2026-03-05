class_name LsgAnimateProxy
extends RefCounted

var _builder: LsgAnimationBuilder


func _init(target: Node2D) -> void:
	_builder = GShapes.AnimationBuilder.new(target)


func set_run_time(seconds: float) -> LsgAnimationBuilder:
	return _builder.set_run_time(seconds)


func set_rate_func(name: StringName) -> LsgAnimationBuilder:
	return _builder.set_rate_func(name)


func move_to(pos: Vector2) -> LsgAnimationBuilder:
	return _builder.move_to(pos)


func set_position(pos: Vector2) -> LsgAnimationBuilder:
	return _builder.set_position(pos)


func shift(delta: Vector2) -> LsgAnimationBuilder:
	return _builder.shift(delta)


func scale_to(new_scale: Variant) -> LsgAnimationBuilder:
	return _builder.scale_to(new_scale)


func rotate_to(rotation_radians: float) -> LsgAnimationBuilder:
	return _builder.rotate_to(rotation_radians)


func set_color(new_color: Color) -> LsgAnimationBuilder:
	return _builder.set_color(new_color)


func set_modulate(new_modulate: Color) -> LsgAnimationBuilder:
	return _builder.set_modulate(new_modulate)


func set_opacity(opacity: float) -> LsgAnimationBuilder:
	return _builder.set_opacity(opacity)


func set_value(new_value: float) -> LsgAnimationBuilder:
	return _builder.set_value(new_value)
