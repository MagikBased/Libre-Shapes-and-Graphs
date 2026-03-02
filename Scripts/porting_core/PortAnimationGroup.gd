class_name PortAnimationGroup
extends PortAnimation

var animations: Array[PortAnimation] = []


func _init(
	p_animations: Array[PortAnimation],
	p_rate_func_name: StringName = &"linear"
) -> void:
	for animation in p_animations:
		if animation != null:
			animations.append(animation)

	var computed_run_time := 0.0001
	for animation in animations:
		computed_run_time = maxf(computed_run_time, animation.run_time)

	super(null, computed_run_time, p_rate_func_name)


func begin() -> void:
	elapsed = 0.0
	finished = false
	for animation in animations:
		animation.begin()

	if animations.is_empty():
		finished = true


func update(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	var all_finished := true
	for animation in animations:
		if not animation.finished:
			animation.update(delta)
		if not animation.finished:
			all_finished = false

	if all_finished:
		finish()


func finish() -> void:
	if finished:
		return
	for animation in animations:
		if not animation.finished:
			animation.finish()
	finished = true


func update_rate_info(
	p_run_time: float = -1.0,
	p_rate_func_name: StringName = &""
) -> PortAnimation:
	var old_total := maxf(0.0001, run_time)
	super.update_rate_info(p_run_time, p_rate_func_name)
	if p_run_time > 0.0:
		var factor := run_time / old_total
		for animation in animations:
			animation.update_rate_info(animation.run_time * factor, p_rate_func_name)
	elif String(p_rate_func_name) != "":
		for animation in animations:
			animation.update_rate_info(-1.0, p_rate_func_name)
	return self
