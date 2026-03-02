class_name PortFadeOut
extends PortAnimation

var start_modulate: Color = Color.WHITE


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	start_modulate = target.modulate


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var c := start_modulate
	c.a = start_modulate.a * (1.0 - clampf(alpha, 0.0, 1.0))
	target.modulate = c
