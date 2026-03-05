class_name GShapesRotate
extends GShapesAnimation

var radians: float = TAU * 0.25
var relative: bool = true

var _start_rotation: float = 0.0
var _end_rotation: float = 0.0


func _init(
	p_target: Node2D,
	p_radians: float = TAU * 0.25,
	p_run_time: float = 0.9,
	p_rate_func_name: StringName = &"smooth",
	p_relative: bool = true
) -> void:
	radians = p_radians
	relative = p_relative
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_start_rotation = target.rotation
	_end_rotation = _start_rotation + radians if relative else radians


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)
	target.rotation = lerp_angle(_start_rotation, _end_rotation, t)



