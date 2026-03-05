# Demo: GShapesDemosSmokeCheck
# Expected behavior: Loads/instantiates each demo scene in-process and reports load status.

extends Node2D

var demo_scenes: Array[String] = []

var seconds_per_scene: float = 1.0
var enable_camera_helper_checks: bool = true
var index: int = -1
var elapsed: float = 0.0
var pass_count: int = 0
var fail_count: int = 0
var active_instance: Node
var failures: Array[String] = []
var camera_check_total: int = 0
var camera_check_pass: int = 0
var camera_check_warn: int = 0
var camera_check_fail: int = 0
var camera_check_messages: Array[String] = []
var phase_counts: Dictionary = {}
var phase8_counts: Dictionary = {}

var status_label: Label
var detail_label: Label


func _ready() -> void:
	status_label = Label.new()
	status_label.position = Vector2(16.0, 12.0)
	status_label.add_theme_font_size_override("font_size", 22)
	add_child(status_label)

	detail_label = Label.new()
	detail_label.position = Vector2(16.0, 48.0)
	detail_label.add_theme_font_size_override("font_size", 16)
	add_child(detail_label)

	demo_scenes = GShapes.DemoCatalog.get_smoke_demos()
	_next_scene()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= seconds_per_scene:
		_next_scene()


func _next_scene() -> void:
	elapsed = 0.0
	index += 1

	if active_instance != null:
		active_instance.queue_free()
		active_instance = null

	if index >= demo_scenes.size():
		var status := "Smoke check complete: pass=%d fail=%d" % [pass_count, fail_count]
		if enable_camera_helper_checks:
			status += " | camera-checks=%d ok=%d warn=%d fail=%d" % [
				camera_check_total,
				camera_check_pass,
				camera_check_warn,
				camera_check_fail,
			]
		status += " | %s" % _phase_coverage_summary()
		status_label.text = status
		var summary_block := _build_summary_block()
		if failures.is_empty():
			detail_label.text = "No failures. Reset to rerun."
			if enable_camera_helper_checks and not camera_check_messages.is_empty():
				detail_label.text += "\nCamera checks:\n" + "\n".join(camera_check_messages)
			detail_label.text += "\n\n" + summary_block
		else:
			detail_label.text = "Failures:\n" + "\n".join(failures)
			if enable_camera_helper_checks and not camera_check_messages.is_empty():
				detail_label.text += "\nCamera checks:\n" + "\n".join(camera_check_messages)
			detail_label.text += "\n\n" + summary_block
		set_process(false)
		_print_summary_to_console(summary_block)
		return

	var path := demo_scenes[index]
	_record_phase_marker(path)
	var ok := _try_load_and_instantiate(path)
	if ok:
		pass_count += 1
	else:
		fail_count += 1
		failures.append(path)

	status_label.text = "Smoke check %d/%d | pass=%d fail=%d" % [index + 1, demo_scenes.size(), pass_count, fail_count]
	detail_label.text = path
	detail_label.text += "\nPhase marker: %s" % _phase_tag_for_scene(path)
	if enable_camera_helper_checks and _is_camera_helper_scene(path):
		detail_label.text += "\n" + _last_camera_check_message()


func _try_load_and_instantiate(path: String) -> bool:
	if not ResourceLoader.exists(path):
		return false
	var packed := load(path) as PackedScene
	if packed == null:
		return false
	active_instance = packed.instantiate()
	if active_instance == null:
		return false
	add_child(active_instance)
	if active_instance is CanvasItem:
		(active_instance as CanvasItem).visible = false
	_run_optional_camera_helper_check(path, active_instance)
	return true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()


func _is_camera_helper_scene(path: String) -> bool:
	return path.ends_with("camera_framing_demo.tscn")


func _run_optional_camera_helper_check(path: String, instance: Node) -> void:
	if not enable_camera_helper_checks:
		return
	if not _is_camera_helper_scene(path):
		return

	camera_check_total += 1
	if instance == null:
		camera_check_fail += 1
		_push_camera_check_message("FAIL %s: scene instance is null" % path)
		return
	if not instance.has_method("get_scene_camera"):
		camera_check_warn += 1
		_push_camera_check_message("WARN %s: get_scene_camera() missing" % path)
		return

	var camera = instance.call("get_scene_camera")
	if camera == null or not (camera is Camera2D):
		camera_check_fail += 1
		_push_camera_check_message("FAIL %s: get_scene_camera() returned invalid camera" % path)
		return

	var cam := camera as Camera2D
	if not cam.enabled:
		camera_check_warn += 1
		_push_camera_check_message("WARN %s: camera exists but is disabled" % path)
		return

	camera_check_pass += 1
	_push_camera_check_message("OK %s: camera helper scene validated" % path)


func _push_camera_check_message(message: String) -> void:
	camera_check_messages.append(message)
	if camera_check_messages.size() > 5:
		camera_check_messages.remove_at(0)
	print("[GShapesDemosSmokeCheck] %s" % message)


func _last_camera_check_message() -> String:
	if camera_check_messages.is_empty():
		return "Camera check: no messages yet."
	return "Camera check: %s" % camera_check_messages[-1]


func _phase_tag_for_scene(path: String) -> String:
	return GShapes.PhaseCoverage.phase_tag_for_scene(path)


func _record_phase_marker(path: String) -> void:
	var phase: String = _phase_tag_for_scene(path)
	phase_counts[phase] = int(phase_counts.get(phase, 0)) + 1
	var phase8: String = GShapes.PhaseCoverage.phase8_tag_for_scene(path)
	phase8_counts[phase8] = int(phase8_counts.get(phase8, 0)) + 1


func _phase_coverage_summary() -> String:
	var ratio6: Vector2i = GShapes.PhaseCoverage.coverage_ratio(phase_counts)
	var ratio8: Vector2i = GShapes.PhaseCoverage.coverage_ratio_phase8(phase8_counts)
	return "phase6_visual=%d/%d | phase8_visual=%d/%d" % [ratio6.x, ratio6.y, ratio8.x, ratio8.y]


func _build_summary_block() -> String:
	var lines: Array[String] = []
	lines.append("[RegressionSummary]")
	lines.append("scenes_total=%d" % demo_scenes.size())
	lines.append("pass=%d" % pass_count)
	lines.append("fail=%d" % fail_count)
	lines.append("%s" % _phase_coverage_summary())
	lines.append("camera_ok=%d" % camera_check_pass)
	lines.append("camera_warn=%d" % camera_check_warn)
	lines.append("camera_fail=%d" % camera_check_fail)
	for tag in GShapes.PhaseCoverage.wanted_phase_tags():
		lines.append("%s=%d" % [tag, int(phase_counts.get(tag, 0))])
	for tag8 in GShapes.PhaseCoverage.wanted_phase8_tags():
		lines.append("%s=%d" % [tag8, int(phase8_counts.get(tag8, 0))])
	if not failures.is_empty():
		lines.append("failed_paths=%s" % ",".join(failures))
	return "\n".join(lines)


func _print_summary_to_console(summary_block: String) -> void:
	print("[GShapesDemosSmokeCheck] Final summary follows")
	print(summary_block)

