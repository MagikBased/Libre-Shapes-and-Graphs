class_name LsgFadeToColor
extends LsgAnimation

var start_color: Color = Color.WHITE
var end_color: Color = Color.WHITE


func _init(
	p_target: Node2D,
	p_start_color: Color,
	p_end_color: Color,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	start_color = p_start_color
	end_color = p_end_color
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target != null:
		target.modulate = start_color


func interpolate(alpha: float) -> void:
	if target == null:
		return
	target.modulate = start_color.lerp(end_color, alpha)
