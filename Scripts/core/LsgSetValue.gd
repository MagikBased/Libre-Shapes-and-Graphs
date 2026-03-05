class_name LsgSetValue
extends LsgAnimation

var start_value: float = 0.0
var end_value: float = 0.0


func _init(
	p_tracker: LsgValueTracker,
	p_end_value: float,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	end_value = p_end_value
	super(p_tracker, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	if target.has_method("get_value"):
		start_value = target.call("get_value")
	else:
		start_value = 0.0


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)
	var value: float = lerpf(start_value, end_value, t)
	if target.has_method("set_value"):
		target.call("set_value", value)
