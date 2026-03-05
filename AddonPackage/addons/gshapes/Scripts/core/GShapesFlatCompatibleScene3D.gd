class_name GShapesFlatCompatibleScene3D
extends GShapesFlatScene3D

var runner: GShapesSceneRunner


func _enter_tree() -> void:
	runner = GShapesSceneRunner.new()
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
		var group: Array[GShapesAnimation] = []
		for item in animation_or_group:
			var animation := _coerce_to_animation(item)
			if animation != null:
				group.append(animation)
		if group.is_empty():
			return
		_queue_with_rate(GShapesAnimationGroup.new(group), run_time, rate_func_name)
		return

	var single := _coerce_to_animation(animation_or_group)
	if single != null:
		_queue_with_rate(single, run_time, rate_func_name)


func play_parallel(
	animations: Array[GShapesAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapesAnimationGroup.new(animations), run_time, rate_func_name)


func play_group(
	animations: Array[GShapesAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	play_parallel(animations, run_time, rate_func_name)


func play_sequence(
	animations: Array[GShapesAnimation],
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapesSequence.new(animations), run_time, rate_func_name)


func play_lagged(
	animations: Array[GShapesAnimation],
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapesLaggedGroup.new(animations, lag_ratio), run_time, rate_func_name)


func play_lagged_map(
	targets: Array,
	animation_factory: Callable,
	lag_ratio: float = 0.2,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	_queue_with_rate(GShapesLaggedMap.new(targets, animation_factory, lag_ratio), run_time, rate_func_name)


func play_map(
	targets: Array,
	animation_factory: Callable,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	var animations: Array[GShapesAnimation] = []
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
	_queue_with_rate(GShapesAnimationGroup.new(animations), run_time, rate_func_name)


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
	animation: GShapesAnimation,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation == null or runner == null:
		return
	animation.update_rate_info(run_time, rate_func_name)
	runner.queue(animation)


func _coerce_to_animation(candidate: Variant) -> GShapesAnimation:
	if candidate is GShapesAnimation:
		return candidate as GShapesAnimation
	if candidate is GShapesAnimationBuilder:
		return (candidate as GShapesAnimationBuilder).build()
	return null




