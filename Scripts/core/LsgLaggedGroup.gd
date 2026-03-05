class_name LsgLaggedGroup
extends LsgAnimation

var animations: Array[LsgAnimation] = []
var lag_ratio: float = 0.2

var _started: Array[bool] = []
var _start_times: Array[float] = []


func _init(
	p_animations: Array[LsgAnimation],
	p_lag_ratio: float = 0.2,
	p_rate_func_name: StringName = &"linear"
) -> void:
	for animation in p_animations:
		if animation != null:
			animations.append(animation)

	lag_ratio = clampf(p_lag_ratio, 0.0, 1.0)
	var computed_run_time := _compute_total_run_time()
	super(null, computed_run_time, p_rate_func_name)


func begin() -> void:
	elapsed = 0.0
	finished = false
	_started.clear()
	_start_times.clear()

	if animations.is_empty():
		finished = true
		return

	var gap := lag_ratio * _max_animation_run_time()
	for i in range(animations.size()):
		_started.append(false)
		_start_times.append(float(i) * gap)


func update(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	var all_finished := true
	for i in range(animations.size()):
		var animation := animations[i]
		if not _started[i] and elapsed >= _start_times[i]:
			animation.begin()
			_started[i] = true

		if _started[i] and not animation.finished:
			animation.update(delta)

		if not animation.finished:
			all_finished = false

	if all_finished:
		finish()


func finish() -> void:
	if finished:
		return
	for i in range(animations.size()):
		var animation := animations[i]
		if _started.size() > i and not _started[i]:
			animation.begin()
			_started[i] = true
		if not animation.finished:
			animation.finish()
	finished = true


func _compute_total_run_time() -> float:
	if animations.is_empty():
		return 0.0001
	var gap := lag_ratio * _max_animation_run_time()
	var total := 0.0
	for i in range(animations.size()):
		total = maxf(total, float(i) * gap + animations[i].run_time)
	return maxf(total, 0.0001)


func _max_animation_run_time() -> float:
	var max_time := 0.0001
	for animation in animations:
		max_time = maxf(max_time, animation.run_time)
	return max_time


func update_rate_info(
	p_run_time: float = -1.0,
	p_rate_func_name: StringName = &""
) -> LsgAnimation:
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
