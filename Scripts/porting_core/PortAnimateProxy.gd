class_name PortAnimateProxy
extends RefCounted

var _builder: PortAnimationBuilder


func _init(target: Node2D) -> void:
	_builder = PortAnimationBuilder.new(target)


func set_run_time(seconds: float) -> PortAnimationBuilder:
	return _builder.set_run_time(seconds)


func set_rate_func(name: StringName) -> PortAnimationBuilder:
	return _builder.set_rate_func(name)


func move_to(pos: Vector2) -> PortAnimationBuilder:
	return _builder.move_to(pos)


func set_position(pos: Vector2) -> PortAnimationBuilder:
	return _builder.set_position(pos)


func shift(delta: Vector2) -> PortAnimationBuilder:
	return _builder.shift(delta)


func scale_to(new_scale: Variant) -> PortAnimationBuilder:
	return _builder.scale_to(new_scale)


func rotate_to(rotation_radians: float) -> PortAnimationBuilder:
	return _builder.rotate_to(rotation_radians)


func set_color(new_color: Color) -> PortAnimationBuilder:
	return _builder.set_color(new_color)


func set_modulate(new_modulate: Color) -> PortAnimationBuilder:
	return _builder.set_modulate(new_modulate)


func set_opacity(opacity: float) -> PortAnimationBuilder:
	return _builder.set_opacity(opacity)


func set_value(new_value: float) -> PortAnimationBuilder:
	return _builder.set_value(new_value)
