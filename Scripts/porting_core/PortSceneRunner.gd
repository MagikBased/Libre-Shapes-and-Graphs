class_name PortSceneRunner
extends Node

signal group_started(group_size: int)
signal group_finished()
signal timeline_empty()

var active_animations: Array[PortAnimation] = []
var queued_groups: Array[Array] = []
var paused: bool = false
var _was_busy_last_frame: bool = false


func play(animation: PortAnimation) -> PortAnimation:
	if animation == null:
		return null
	animation.begin()
	active_animations.append(animation)
	_was_busy_last_frame = true
	return animation


func play_many(animations: Array[PortAnimation]) -> void:
	for animation in animations:
		play(animation)


func queue(animation: PortAnimation) -> void:
	if animation == null:
		return
	queue_many([animation])


func queue_many(animations: Array[PortAnimation]) -> void:
	var group: Array[PortAnimation] = []
	for animation in animations:
		if animation != null:
			group.append(animation)
	if group.is_empty():
		return

	queued_groups.append(group)
	if active_animations.is_empty():
		_start_next_group()


func wait_seconds(duration: float) -> void:
	queue(PortWait.new(duration))


func _start_next_group() -> void:
	if queued_groups.is_empty():
		return

	var next_group: Array = queued_groups.pop_front()
	group_started.emit(next_group.size())
	for animation in next_group:
		animation.begin()
		active_animations.append(animation)
	_was_busy_last_frame = true


func pause() -> void:
	paused = true


func resume() -> void:
	paused = false


func toggle_pause() -> void:
	paused = not paused


func is_paused() -> bool:
	return paused


func clear() -> void:
	active_animations.clear()
	queued_groups.clear()
	_was_busy_last_frame = false


func is_busy() -> bool:
	return active_animations.size() > 0 or queued_groups.size() > 0


func _process(delta: float) -> void:
	if paused:
		return

	for i in range(active_animations.size() - 1, -1, -1):
		var animation := active_animations[i]
		animation.update(delta)
		if animation.finished:
			active_animations.remove_at(i)

	var is_busy_now := not active_animations.is_empty() or not queued_groups.is_empty()
	if active_animations.is_empty() and _was_busy_last_frame:
		group_finished.emit()
		if not queued_groups.is_empty():
			_start_next_group()
		else:
			timeline_empty.emit()

	_was_busy_last_frame = is_busy_now
