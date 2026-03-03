# Demo: PortDemosRunner
# Expected behavior: Auto-cycle and manually cycle all port demos in one scene.

extends Node2D

var demo_scenes: Array[String] = []

var seconds_per_demo: float = 5.0
var auto_advance: bool = true

var index: int = 0
var elapsed: float = 0.0
var active_demo: Node
var active_demo_path: String = ""

var hud_layer: CanvasLayer
var hud_panel: ColorRect
var title_label: Label
var scene_label: Label
var hint_label: Label
var check_label: Label
var _runner_logs: Array[String] = []
var _phase_counts: Dictionary = {}


func _ready() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 100
	add_child(hud_layer)

	hud_panel = ColorRect.new()
	hud_panel.color = Color(0.02, 0.03, 0.05, 0.88)
	hud_panel.position = Vector2.ZERO
	hud_panel.size = Vector2(1400.0, 140.0)
	hud_layer.add_child(hud_panel)

	title_label = Label.new()
	title_label.text = "Port Demos Runner"
	title_label.position = Vector2(16.0, 10.0)
	title_label.add_theme_font_size_override("font_size", 30)
	hud_layer.add_child(title_label)

	scene_label = Label.new()
	scene_label.position = Vector2(16.0, 52.0)
	scene_label.add_theme_font_size_override("font_size", 18)
	hud_layer.add_child(scene_label)

	hint_label = Label.new()
	hint_label.text = "Next/Prev Scene: cycle | Enter: reload demo | Reset: toggle auto-run"
	hint_label.position = Vector2(16.0, 78.0)
	hint_label.add_theme_font_size_override("font_size", 14)
	hud_layer.add_child(hint_label)

	check_label = Label.new()
	check_label.position = Vector2(16.0, 102.0)
	check_label.add_theme_font_size_override("font_size", 13)
	check_label.modulate = Color(0.82, 0.92, 1.0)
	check_label.text = "Checks: (none yet)"
	hud_layer.add_child(check_label)

	demo_scenes = PortDemoCatalog.get_runner_demos()
	_load_demo(index)


func _process(delta: float) -> void:
	if not auto_advance:
		return
	elapsed += delta
	if elapsed >= seconds_per_demo:
		_next_demo()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Next Scene"):
		_next_demo()
	elif event.is_action_pressed("Previous Scene"):
		index = posmod(index - 1, max(1, demo_scenes.size()))
		_load_demo(index)
	elif event.is_action_pressed("ui_accept"):
		_load_demo(index)
	elif event.is_action_pressed("Reset"):
		auto_advance = not auto_advance
		_refresh_labels()


func _next_demo() -> void:
	index = (index + 1) % max(1, demo_scenes.size())
	_load_demo(index)


func _load_demo(new_index: int) -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		return

	elapsed = 0.0
	index = clampi(new_index, 0, demo_scenes.size() - 1)
	if active_demo != null:
		active_demo.queue_free()
		active_demo = null

	var path := demo_scenes[index]
	active_demo_path = path
	_record_phase_marker(path)
	if not ResourceLoader.exists(path):
		scene_label.text = "Missing demo: %s" % path
		_append_check_log("ERROR missing demo resource: %s" % path)
		return

	var packed := load(path) as PackedScene
	if packed == null:
		scene_label.text = "Invalid scene: %s" % path
		_append_check_log("ERROR invalid packed scene: %s" % path)
		return

	active_demo = packed.instantiate()
	add_child(active_demo)
	if active_demo is CanvasItem:
		(active_demo as CanvasItem).z_index = -10

	_run_lightweight_checks(active_demo_path)
	_refresh_labels()


func _refresh_labels() -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		return
	scene_label.text = "%d/%d | %s | auto:%s | %.1fs" % [
		index + 1,
		demo_scenes.size(),
		demo_scenes[index],
		"on" if auto_advance else "off",
		seconds_per_demo
	]
	var phase := _phase_tag_for_scene(demo_scenes[index])
	var covered := _phase_coverage_summary()
	scene_label.text += " | phase:%s | %s" % [phase, covered]
	check_label.text = "Checks: %s" % (_runner_logs[-1] if not _runner_logs.is_empty() else "(none yet)")


func _run_lightweight_checks(path: String) -> void:
	if active_demo == null:
		return
	# Camera helper assertions are only meaningful for the camera framing demo.
	if not path.ends_with("camera_framing_demo.tscn"):
		return
	_validate_camera_helper_scene(active_demo, path)


func _validate_camera_helper_scene(scene_root: Node, path: String) -> void:
	if scene_root == null:
		_append_check_log("ERROR %s: instance is null" % path)
		return
	if not scene_root.has_method("get_scene_camera"):
		_append_check_log("WARN %s: get_scene_camera() missing" % path)
		push_warning("Runner check: camera helper method missing in %s" % path)
		return

	var camera = scene_root.call("get_scene_camera")
	if camera == null or not (camera is Camera2D):
		_append_check_log("ERROR %s: camera helper returned invalid camera" % path)
		push_error("Runner check: invalid camera in %s" % path)
		return

	var cam := camera as Camera2D
	if not cam.enabled:
		_append_check_log("WARN %s: camera exists but is disabled" % path)
		push_warning("Runner check: camera disabled in %s" % path)
		return

	_append_check_log("OK %s: camera helper scene validated" % path)


func _append_check_log(message: String) -> void:
	_runner_logs.append(message)
	if _runner_logs.size() > 10:
		_runner_logs.remove_at(0)
	print("[PortDemosRunner] %s" % message)


func _phase_tag_for_scene(path: String) -> String:
	return PortPhaseCoverage.phase_tag_for_scene(path)


func _record_phase_marker(path: String) -> void:
	var phase := _phase_tag_for_scene(path)
	_phase_counts[phase] = int(_phase_counts.get(phase, 0)) + 1


func _phase_coverage_summary() -> String:
	var ratio := PortPhaseCoverage.coverage_ratio(_phase_counts)
	return "phase6_visual=%d/%d" % [ratio.x, ratio.y]
