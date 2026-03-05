class_name LsgAnimation
extends RefCounted

var target: Node2D
var run_time: float = 1.0
var elapsed: float = 0.0
var rate_func_name: StringName = &"smooth"
var finished: bool = false


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	target = p_target
	run_time = maxf(0.0001, p_run_time)
	rate_func_name = p_rate_func_name


func begin() -> void:
	elapsed = 0.0
	finished = false
	on_begin()
	interpolate(0.0)


func update(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	var alpha: float = clampf(elapsed / run_time, 0.0, 1.0)
	var eased_alpha: float = GShapes.RateFunctions.apply(rate_func_name, alpha)
	interpolate(eased_alpha)

	if alpha >= 1.0:
		finish()


func finish() -> void:
	if finished:
		return
	interpolate(1.0)
	finished = true
	on_finish()


func on_begin() -> void:
	pass


func on_finish() -> void:
	pass


func interpolate(_alpha: float) -> void:
	pass


func update_rate_info(
	p_run_time: float = -1.0,
	p_rate_func_name: StringName = &""
) -> LsgAnimation:
	if p_run_time > 0.0:
		run_time = maxf(0.0001, p_run_time)
	if String(p_rate_func_name) != "":
		rate_func_name = p_rate_func_name
	return self
