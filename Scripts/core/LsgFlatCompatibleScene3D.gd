class_name LsgFlatCompatibleScene3D
extends LsgFlatScene3D

var runner: LsgSceneRunner


func _enter_tree() -> void:
	runner = GShapes.SceneRunner.new()
	add_child(runner)


func add_flat_child(node: Node) -> void:
	var root: Node2D = get_canvas_root()
	if root == null or node == null:
		return
	root.add_child(node)


func play(
	animation_or_group: Variant,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation_or_group is Array:
		var group: Array[LsgAnimation] = []
		for item in animation_or_group:
			var animation := _coerce_to_animation(item)
			if animation != null:
				group.append(animation)
		if group.is_empty():
			return
		_queue_with_rate(GShapes.AnimationGroup.new(group), run_time, rate_func_name)
		return

	var single := _coerce_to_animation(animation_or_group)
	if single != null:
		_queue_with_rate(single, run_time, rate_func_name)


func play_parallel(
	animations: Array[LsgAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapes.AnimationGroup.new(animations), run_time, rate_func_name)


func play_group(
	animations: Array[LsgAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	play_parallel(animations, run_time, rate_func_name)


func play_sequence(
	animations: Array[LsgAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapes.Sequence.new(animations), run_time, rate_func_name)


func play_lagged(
	animations: Array[LsgAnimation],
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapes.LaggedGroup.new(animations, lag_ratio), run_time, rate_func_name)


func play_lagged_map(
	targets: Array,
	animation_factory: Callable,
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapes.LaggedMap.new(targets, animation_factory, lag_ratio), run_time, rate_func_name)


func play_map(
	targets: Array,
	animation_factory: Callable,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	var animations: Array[LsgAnimation] = []
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
	_queue_with_rate(GShapes.AnimationGroup.new(animations), run_time, rate_func_name)


func wait_seconds(duration: float) -> void:
	if runner == null:
		return
	runner.wait_seconds(duration)


func wait(duration: float = 1.0) -> void:
	wait_seconds(duration)


func clear_timeline() -> void:
	if runner == null:
		return
	runner.clear()


func is_playing() -> bool:
	return runner != null and runner.is_busy()


func pause_timeline() -> void:
	if runner == null:
		return
	runner.pause()


func resume_timeline() -> void:
	if runner == null:
		return
	runner.resume()


func toggle_timeline_pause() -> void:
	if runner == null:
		return
	runner.toggle_pause()


func is_timeline_paused() -> bool:
	return runner != null and runner.is_paused()


func _queue_with_rate(
	animation: LsgAnimation,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation == null or runner == null:
		return
	animation.update_rate_info(run_time, rate_func_name)
	runner.queue(animation)


func _coerce_to_animation(candidate: Variant) -> LsgAnimation:
	if candidate is LsgAnimation:
		return candidate as LsgAnimation
	if candidate is LsgAnimationBuilder:
		return (candidate as LsgAnimationBuilder).build()
	return null
