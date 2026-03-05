# Demo: TimelineControlsDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var status_label: Label
var event_label: Label
var dot: Circle
var _running_in_demos_runner: bool = false


func _ready() -> void:
	_running_in_demos_runner = get_parent() != null and get_parent().name == "GShapesDemosRunner"
	if not _running_in_demos_runner:
		_create_caption("Timeline controls demo: Enter toggles pause, Reset reloads scene")
		_create_status_labels()

	runner.group_started.connect(_on_group_started)
	runner.group_finished.connect(_on_group_finished)
	runner.timeline_empty.connect(_on_timeline_empty)

	dot = Circle.new()
	dot.size = Vector2(46.0, 46.0)
	dot.color = Color.ORANGE_RED
	dot.position = Vector2(140.0, 360.0)
	add_child(dot)

	play_sequence([
		GShapes.MoveTo.new(dot, Vector2(1040.0, 360.0), 1.6, &"smooth"),
		GShapes.MoveTo.new(dot, Vector2(140.0, 360.0), 1.6, &"smooth"),
		GShapes.MoveTo.new(dot, Vector2(1040.0, 360.0), 1.6, &"smooth"),
	])
	_refresh_status()


func _input(event: InputEvent) -> void:
	if _running_in_demos_runner:
		return
	if event.is_action_pressed("ui_accept"):
		toggle_timeline_pause()
		_refresh_status()
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()


func _on_group_started(group_size: int) -> void:
	if event_label != null:
		event_label.text = "Event: group_started(size=%d)" % group_size
	_refresh_status()


func _on_group_finished() -> void:
	if event_label != null:
		event_label.text = "Event: group_finished"
	_refresh_status()


func _on_timeline_empty() -> void:
	if event_label != null:
		event_label.text = "Event: timeline_empty"
	_refresh_status()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)


func _create_status_labels() -> void:
	status_label = Label.new()
	status_label.position = Vector2(16.0, 44.0)
	status_label.modulate = Color(0.85, 0.92, 1.0)
	add_child(status_label)

	event_label = Label.new()
	event_label.position = Vector2(16.0, 68.0)
	event_label.modulate = Color(0.7, 0.9, 0.9)
	event_label.text = "Event: (none yet)"
	add_child(event_label)


func _refresh_status() -> void:
	if status_label == null:
		return
	status_label.text = "Status: playing=%s paused=%s queued=%d active=%d" % [
		str(is_playing()),
		str(is_timeline_paused()),
		runner.queued_groups.size(),
		runner.active_animations.size(),
	]


func get_runner_controls_hint() -> String:
	return "Timeline controls disabled in runner"




