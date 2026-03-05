class_name GShapesTracedPath2D
extends GShapesPolylineMobject

var target_node: Node2D
var point_callable: Callable
var min_distance: float = 2.0
var max_points: int = 0
var local_space: bool = true
var enabled_tracing: bool = true


func _process(delta: float) -> void:
	super._process(delta)
	if not enabled_tracing:
		return
	_append_current_point()


func clear_trace() -> void:
	points = PackedVector2Array()
	queue_redraw()


func set_target(node: Node2D) -> void:
	target_node = node


func set_point_callable(source: Callable) -> void:
	point_callable = source


func _append_current_point() -> void:
	var point: Variant = _sample_world_point()
	if point == null:
		return

	var sampled: Vector2 = point as Vector2
	if local_space:
		sampled = to_local(sampled)

	var should_append := true
	if points.size() > 0:
		should_append = points[-1].distance_to(sampled) >= maxf(0.0, min_distance)
	if not should_append:
		return

	var next_points: PackedVector2Array = points
	next_points.append(sampled)
	if max_points > 0 and next_points.size() > max_points:
		var trim_count := next_points.size() - max_points
		for _i in range(trim_count):
			next_points.remove_at(0)
	points = next_points
	queue_redraw()


func _sample_world_point() -> Variant:
	if point_callable.is_valid():
		var v: Variant = point_callable.call()
		if v is Vector2:
			return v
	if target_node != null and is_instance_valid(target_node):
		return target_node.global_position
	return null



