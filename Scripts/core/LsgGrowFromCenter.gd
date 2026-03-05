class_name LsgGrowFromCenter
extends LsgAnimation

var _final_scale: Vector2 = Vector2.ONE
var _min_scale: float = 0.001


func _init(
	p_target: Node2D,
	p_run_time: float = 0.8,
	p_rate_func_name: StringName = &"smooth",
	p_min_scale: float = 0.001
) -> void:
	_min_scale = maxf(0.0001, p_min_scale)
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_final_scale = target.scale
	target.scale = Vector2.ONE * _min_scale


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)
	target.scale = (Vector2.ONE * _min_scale).lerp(_final_scale, t)
