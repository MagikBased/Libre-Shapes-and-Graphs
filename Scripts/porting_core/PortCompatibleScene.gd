class_name PortCompatibleScene
extends Node2D

var runner: PortSceneRunner


func _enter_tree() -> void:
	runner = PortSceneRunner.new()
	add_child(runner)


func play(
	animation_or_group: Variant,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation_or_group is Array:
		var group: Array[PortAnimation] = []
		for item in animation_or_group:
			var animation := _coerce_to_animation(item)
			if animation != null:
				group.append(animation)
		if group.is_empty():
			return
		_queue_with_rate(PortAnimationGroup.new(group), run_time, rate_func_name)
		return

	var single := _coerce_to_animation(animation_or_group)
	if single != null:
		_queue_with_rate(single, run_time, rate_func_name)


func play_parallel(
	animations: Array[PortAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(PortAnimationGroup.new(animations), run_time, rate_func_name)


func play_group(
	animations: Array[PortAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	play_parallel(animations, run_time, rate_func_name)


func play_sequence(
	animations: Array[PortAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(PortSequence.new(animations), run_time, rate_func_name)


func play_lagged(
	animations: Array[PortAnimation],
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(PortLaggedGroup.new(animations, lag_ratio), run_time, rate_func_name)


func play_lagged_map(
	targets: Array,
	animation_factory: Callable,
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(PortLaggedMap.new(targets, animation_factory, lag_ratio), run_time, rate_func_name)


func play_map(
	targets: Array,
	animation_factory: Callable,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	var animations: Array[PortAnimation] = []
	var arg_count := animation_factory.get_argument_count()
	for i in range(targets.size()):
		var result = null
		if arg_count <= 0:
			result = animation_factory.call()
		elif arg_count == 1:
			result = animation_factory.call(targets[i])
		else:
			result = animation_factory.call(targets[i], i)
		var mapped := _coerce_to_animation(result)
		if mapped != null:
			animations.append(mapped)
	if animations.is_empty():
		return
	_queue_with_rate(PortAnimationGroup.new(animations), run_time, rate_func_name)


func wait_seconds(duration: float) -> void:
	runner.wait_seconds(duration)


func wait(duration: float = 1.0) -> void:
	wait_seconds(duration)


func clear_timeline() -> void:
	runner.clear()


func is_playing() -> bool:
	return runner.is_busy()


func pause_timeline() -> void:
	runner.pause()


func resume_timeline() -> void:
	runner.resume()


func toggle_timeline_pause() -> void:
	runner.toggle_pause()


func is_timeline_paused() -> bool:
	return runner.is_paused()


func _queue_with_rate(
	animation: PortAnimation,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation == null:
		return
	animation.update_rate_info(run_time, rate_func_name)
	runner.queue(animation)


func _coerce_to_animation(candidate: Variant) -> PortAnimation:
	if candidate is PortAnimation:
		return candidate as PortAnimation
	if candidate is PortAnimationBuilder:
		return (candidate as PortAnimationBuilder).build()
	return null
