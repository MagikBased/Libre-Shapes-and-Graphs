class_name GShapesFadeIn
extends GShapesAnimation

var final_modulate: Color = Color.WHITE


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	final_modulate = target.modulate
	var transparent_start := final_modulate
	transparent_start.a = 0.0
	target.modulate = transparent_start


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var c := final_modulate
	c.a = final_modulate.a * clampf(alpha, 0.0, 1.0)
	target.modulate = c



