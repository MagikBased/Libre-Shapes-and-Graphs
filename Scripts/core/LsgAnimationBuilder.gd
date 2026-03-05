class_name LsgAnimationBuilder
extends RefCounted

var target: Node2D
var run_time: float = 1.0
var rate_func_name: StringName = &"smooth"

var _animate_position: bool = false
var _position_is_delta: bool = false
var _end_position: Vector2 = Vector2.ZERO

var _animate_scale: bool = false
var _end_scale: Vector2 = Vector2.ONE

var _animate_rotation: bool = false
var _end_rotation: float = 0.0

var _animate_color: bool = false
var _end_color: Color = Color.WHITE

var _animate_modulate: bool = false
var _end_modulate: Color = Color.WHITE

var _animate_value: bool = false
var _end_value: float = 0.0


func _init(p_target: Node2D) -> void:
	target = p_target


func set_run_time(seconds: float) -> LsgAnimationBuilder:
	run_time = maxf(0.0001, seconds)
	return self


func set_rate_func(name: StringName) -> LsgAnimationBuilder:
	rate_func_name = name
	return self


func move_to(pos: Vector2) -> LsgAnimationBuilder:
	_animate_position = true
	_position_is_delta = false
	_end_position = pos
	return self


func set_position(pos: Vector2) -> LsgAnimationBuilder:
	return move_to(pos)


func shift(delta: Vector2) -> LsgAnimationBuilder:
	_animate_position = true
	if not _position_is_delta:
		_position_is_delta = true
		_end_position = Vector2.ZERO
	_end_position += delta
	return self


func scale_to(new_scale: Variant) -> LsgAnimationBuilder:
	_animate_scale = true
	if new_scale is float:
		_end_scale = Vector2.ONE * float(new_scale)
	elif new_scale is Vector2:
		_end_scale = new_scale
	return self


func rotate_to(rotation_radians: float) -> LsgAnimationBuilder:
	_animate_rotation = true
	_end_rotation = rotation_radians
	return self


func set_color(new_color: Color) -> LsgAnimationBuilder:
	_animate_color = true
	_end_color = new_color
	return self


func set_modulate(new_modulate: Color) -> LsgAnimationBuilder:
	_animate_modulate = true
	_end_modulate = new_modulate
	return self


func set_opacity(opacity: float) -> LsgAnimationBuilder:
	_animate_modulate = true
	var c := _end_modulate
	c.a = clampf(opacity, 0.0, 1.0)
	_end_modulate = c
	return self


func set_value(new_value: float) -> LsgAnimationBuilder:
	_animate_value = true
	_end_value = new_value
	return self


func build() -> LsgAnimation:
	var anim: LsgAnimateStateAnimation = GShapes.AnimateStateAnimation.new(target, run_time, rate_func_name)
	anim.animate_position = _animate_position
	anim.position_is_delta = _position_is_delta
	anim.end_position = _end_position
	anim.animate_scale = _animate_scale
	anim.end_scale = _end_scale
	anim.animate_rotation = _animate_rotation
	anim.end_rotation = _end_rotation
	anim.animate_color = _animate_color
	anim.end_color = _end_color
	anim.animate_modulate = _animate_modulate
	anim.end_modulate = _end_modulate
	anim.animate_value = _animate_value
	anim.end_value = _end_value
	return anim
