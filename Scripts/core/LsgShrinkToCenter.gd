class_name LsgShrinkToCenter
extends LsgAnimation

var _start_scale: Vector2 = Vector2.ONE
var _end_scale: Vector2 = Vector2.ONE * 0.001


func _init(
	p_target: Node2D,
	p_run_time: float = 0.8,
	p_rate_func_name: StringName = &"smooth",
	p_end_scale: float = 0.001
) -> void:
	_end_scale = Vector2.ONE * maxf(0.0001, p_end_scale)
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_start_scale = target.scale


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)
	target.scale = _start_scale.lerp(_end_scale, t)
