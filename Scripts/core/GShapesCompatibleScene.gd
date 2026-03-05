class_name GShapesCompatibleScene
extends Node2D

var runner: GShapesSceneRunner
var scene_camera: Camera2D


func _enter_tree() -> void:
	runner = GShapesSceneRunner.new()
	add_child(runner)


func get_scene_camera() -> Camera2D:
	return _ensure_scene_camera()


func move_camera(
	to_world_position: Vector2,
	run_time: float = 1.0,
	rate_func_name: StringName = &"smooth"
) -> void:
	var camera := _ensure_scene_camera()
	play(GShapesMoveTo.new(camera, to_world_position, run_time, rate_func_name))


func zoom_camera(
	to_zoom: Vector2,
	run_time: float = 1.0,
	rate_func_name: StringName = &"smooth"
) -> void:
	var camera := _ensure_scene_camera()
	play(GShapesCameraZoomTo.new(camera, to_zoom, run_time, rate_func_name))


func zoom_to_fit(
	targets: Array,
	padding_ratio: float = 0.12,
	run_time: float = 1.0,
	rate_func_name: StringName = &"smooth"
) -> void:
	if targets.is_empty():
		return
	var fit_rect := _compute_fit_rect(targets, padding_ratio)
	var center := fit_rect.get_center()
	var viewport_size := get_viewport_rect().size
	viewport_size.x = maxf(1.0, viewport_size.x)
	viewport_size.y = maxf(1.0, viewport_size.y)
	var zoom_factor := maxf(
		fit_rect.size.x / viewport_size.x,
		fit_rect.size.y / viewport_size.y
	)
	zoom_factor = maxf(0.05, zoom_factor)
	play([
		GShapesMoveTo.new(_ensure_scene_camera(), center, run_time, rate_func_name),
		GShapesCameraZoomTo.new(_ensure_scene_camera(), Vector2.ONE * zoom_factor, run_time, rate_func_name),
	])


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
	animation: GShapesAnimation,
	run_time: float = -1.0,
	rate_func_name: StringName = &""
) -> void:
	if animation == null:
		return
	animation.update_rate_info(run_time, rate_func_name)
	runner.queue(animation)


func _coerce_to_animation(candidate: Variant) -> GShapesAnimation:
	if candidate is GShapesAnimation:
		return candidate as GShapesAnimation
	if candidate is GShapesAnimationBuilder:
		return (candidate as GShapesAnimationBuilder).build()
	return null


func _ensure_scene_camera() -> Camera2D:
	if scene_camera != null and is_instance_valid(scene_camera):
		_make_scene_camera_current_safe()
		return scene_camera

	scene_camera = Camera2D.new()
	scene_camera.name = "GShapesSceneCamera2D"
	scene_camera.enabled = true
	add_child(scene_camera)
	call_deferred("_make_scene_camera_current_safe")
	return scene_camera


func _make_scene_camera_current_safe() -> void:
	if scene_camera == null or not is_instance_valid(scene_camera):
		return
	if not scene_camera.enabled:
		scene_camera.enabled = true
	if not scene_camera.is_inside_tree():
		call_deferred("_make_scene_camera_current_safe")
		return
	scene_camera.make_current()


func _compute_fit_rect(targets: Array, padding_ratio: float) -> Rect2:
	var has_point := false
	var min_v := Vector2.ZERO
	var max_v := Vector2.ZERO

	for target in targets:
		if target is Vector2:
			var p := target as Vector2
			if not has_point:
				min_v = p
				max_v = p
				has_point = true
			else:
				min_v.x = minf(min_v.x, p.x)
				min_v.y = minf(min_v.y, p.y)
				max_v.x = maxf(max_v.x, p.x)
				max_v.y = maxf(max_v.y, p.y)
		elif target is Rect2:
			var r := target as Rect2
			var p0 := r.position
			var p1 := r.position + r.size
			var local_min := Vector2(minf(p0.x, p1.x), minf(p0.y, p1.y))
			var local_max := Vector2(maxf(p0.x, p1.x), maxf(p0.y, p1.y))
			if not has_point:
				min_v = local_min
				max_v = local_max
				has_point = true
			else:
				min_v.x = minf(min_v.x, local_min.x)
				min_v.y = minf(min_v.y, local_min.y)
				max_v.x = maxf(max_v.x, local_max.x)
				max_v.y = maxf(max_v.y, local_max.y)
		elif target is Node2D:
			var node := target as Node2D
			var gp := node.global_position
			if not has_point:
				min_v = gp
				max_v = gp
				has_point = true
			else:
				min_v.x = minf(min_v.x, gp.x)
				min_v.y = minf(min_v.y, gp.y)
				max_v.x = maxf(max_v.x, gp.x)
				max_v.y = maxf(max_v.y, gp.y)

	if not has_point:
		return Rect2(Vector2.ZERO, Vector2(1.0, 1.0))

	var rect := Rect2(min_v, max_v - min_v)
	rect.size.x = maxf(1.0, rect.size.x)
	rect.size.y = maxf(1.0, rect.size.y)
	var pad := rect.size * maxf(0.0, padding_ratio)
	rect.position -= pad
	rect.size += pad * 2.0
	return rect




