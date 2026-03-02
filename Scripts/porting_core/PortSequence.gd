class_name PortSequence
extends PortAnimation

var animations: Array[PortAnimation] = []
var current_index: int = -1


func _init(
	p_animations: Array[PortAnimation],
	p_rate_func_name: StringName = &"linear"
) -> void:
	for animation in p_animations:
		if animation != null:
			animations.append(animation)

	var computed_run_time := 0.0001
	for animation in animations:
		computed_run_time += animation.run_time

	super(null, computed_run_time, p_rate_func_name)


func begin() -> void:
	elapsed = 0.0
	finished = false
	current_index = -1
	_start_next_animation()


func update(delta: float) -> void:
	if finished:
		return

	elapsed += delta
	if current_index < 0 or current_index >= animations.size():
		finish()
		return

	var current := animations[current_index]
	current.update(delta)
	if current.finished:
		_start_next_animation()


func finish() -> void:
	if finished:
		return
	for i in range(current_index, animations.size()):
		if i >= 0 and not animations[i].finished:
			animations[i].finish()
	finished = true


func _start_next_animation() -> void:
	current_index += 1
	if current_index >= animations.size():
		finish()
		return

	var next := animations[current_index]
	next.begin()

	# Handle instant animations immediately so sequences cannot stall.
	if next.finished:
		_start_next_animation()


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
