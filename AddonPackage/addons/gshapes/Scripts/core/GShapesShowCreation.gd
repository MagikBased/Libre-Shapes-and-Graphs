class_name GShapesShowCreation
extends GShapesAnimation


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target != null and target.has_method("set_draw_progress"):
		target.call("set_draw_progress", 0.0)


func interpolate(alpha: float) -> void:
	if target == null:
		return
	if target.has_method("set_draw_progress"):
		target.call("set_draw_progress", alpha)



