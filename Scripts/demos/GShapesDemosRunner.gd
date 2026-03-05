# Demo: GShapesDemosRunner
# Expected behavior: Auto-cycle and manually cycle all demos in one scene.

extends Node2D

const HUD_HEIGHT: float = 70.0
const HUD_LEFT_MARGIN: float = 20.0
const HUD_TOP_MARGIN: float = 14.0

var demo_scenes: Array[String] = []

var seconds_per_demo: float = 3.0
var max_seconds_per_demo: float = 12.0
var auto_advance: bool = true

var index: int = 0
var elapsed: float = 0.0
var active_demo: Node
var active_demo_path: String = ""

var hud_layer: CanvasLayer
var hud_panel: ColorRect
var scene_label: Label
var hint_label: Label
var _runner_logs: Array[String] = []
var _phase_counts: Dictionary = {}
var _phase8_counts: Dictionary = {}
var _completed_cycles: int = 0


func _ready() -> void:
	var root_viewport := get_viewport()
	if root_viewport != null:
		root_viewport.size_changed.connect(_on_root_viewport_size_changed)

	hud_layer = CanvasLayer.new()
	hud_layer.layer = 100
	add_child(hud_layer)

	hud_panel = ColorRect.new()
	hud_panel.color = Color(0.02, 0.03, 0.05, 0.0)
	hud_panel.position = Vector2.ZERO
	hud_panel.size = Vector2(1400.0, HUD_HEIGHT)
	hud_layer.add_child(hud_panel)

	scene_label = Label.new()
	scene_label.position = Vector2(HUD_LEFT_MARGIN, HUD_TOP_MARGIN)
	scene_label.add_theme_font_size_override("font_size", 30)
	hud_layer.add_child(scene_label)

	hint_label = Label.new()
	hint_label.position = Vector2(HUD_LEFT_MARGIN, HUD_TOP_MARGIN + 36.0)
	hint_label.add_theme_font_size_override("font_size", 14)
	hud_layer.add_child(hint_label)
	_sync_demo_viewport_size()

	demo_scenes = GShapes.DemoCatalog.get_runner_demos()
	_load_demo(index)


func _process(delta: float) -> void:
	if not auto_advance:
		return
	elapsed += delta
	if elapsed < seconds_per_demo:
		return
	var still_playing: bool = _demo_is_still_playing()
	if still_playing:
		# Keep long-running/interactive demos on-screen until they settle,
		# but never exceed the safety cap.
		if elapsed < max_seconds_per_demo:
			return
		_next_demo()
		return
	# If the scene has finished its timeline and minimum hold time elapsed,
	# move on immediately instead of idling to the old fixed dwell.
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
	var next_index: int = (index + 1) % max(1, demo_scenes.size())
	if next_index == 0 and not demo_scenes.is_empty():
		_completed_cycles += 1
		_print_cycle_summary()
	index = next_index
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

	var path: String = demo_scenes[index]
	active_demo_path = path
	_record_phase_marker(path)
	if not ResourceLoader.exists(path):
		scene_label.text = "Missing demo: %s" % path
		_append_check_log("ERROR missing demo resource: %s" % path)
		return

	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		scene_label.text = "Invalid scene: %s" % path
		_append_check_log("ERROR invalid packed scene: %s" % path)
		return

	active_demo = packed.instantiate()
	add_child(active_demo)
	if active_demo is CanvasItem:
		(active_demo as CanvasItem).z_index = -10
	_suppress_demo_caption_labels(active_demo)

	_run_lightweight_checks(active_demo_path)
	_refresh_labels()


func _refresh_labels() -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		hint_label.text = "Controls: Next/Prev cycle | Enter reload demo | Reset auto-run"
		return
	scene_label.text = "%d/%d | %s" % [
		index + 1,
		demo_scenes.size(),
		_scene_title_for_path(demo_scenes[index]),
	]
	var controls: String = "%s | Controls: Next/Prev cycle | Enter reload demo | Reset auto-run (%s)" % [
		_phase_coverage_summary(),
		"on" if auto_advance else "off"
	]
	if active_demo != null and active_demo.has_method("get_runner_controls_hint"):
		var demo_controls: String = str(active_demo.call("get_runner_controls_hint")).strip_edges()
		if not demo_controls.is_empty():
			controls += " | %s" % demo_controls
	hint_label.text = controls


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

	var camera: Variant = scene_root.call("get_scene_camera")
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
	print("[GShapesDemosRunner] %s" % message)


func _phase_tag_for_scene(path: String) -> String:
	return GShapes.PhaseCoverage.phase_tag_for_scene(path)


func _record_phase_marker(path: String) -> void:
	var phase: String = _phase_tag_for_scene(path)
	_phase_counts[phase] = int(_phase_counts.get(phase, 0)) + 1
	var phase8: String = GShapes.PhaseCoverage.phase8_tag_for_scene(path)
	_phase8_counts[phase8] = int(_phase8_counts.get(phase8, 0)) + 1


func _phase_coverage_summary() -> String:
	var ratio6: Vector2i = GShapes.PhaseCoverage.coverage_ratio(_phase_counts)
	var ratio8: Vector2i = GShapes.PhaseCoverage.coverage_ratio_phase8(_phase8_counts)
	return "phase6_visual=%d/%d | phase8_visual=%d/%d" % [ratio6.x, ratio6.y, ratio8.x, ratio8.y]


func _build_cycle_summary_block() -> String:
	var lines: Array[String] = []
	lines.append("[RunnerSummary]")
	lines.append("cycles=%d" % _completed_cycles)
	lines.append("scenes_total=%d" % demo_scenes.size())
	lines.append("%s" % _phase_coverage_summary())
	for tag in GShapes.PhaseCoverage.wanted_phase_tags():
		lines.append("%s=%d" % [tag, int(_phase_counts.get(tag, 0))])
	for tag8 in GShapes.PhaseCoverage.wanted_phase8_tags():
		lines.append("%s=%d" % [tag8, int(_phase8_counts.get(tag8, 0))])
	return "\n".join(lines)


func _print_cycle_summary() -> void:
	print("[GShapesDemosRunner] Completed demo cycle %d" % _completed_cycles)
	print(_build_cycle_summary_block())


func _on_root_viewport_size_changed() -> void:
	_sync_demo_viewport_size()


func _sync_demo_viewport_size() -> void:
	if hud_panel != null:
		hud_panel.size.x = maxf(1.0, get_viewport_rect().size.x)


func _scene_title_for_path(path: String) -> String:
	var base: String = path.get_file().get_basename()
	for suffix in ["_parity_demo", "_demo", "_port"]:
		if base.ends_with(suffix):
			base = base.substr(0, base.length() - suffix.length())
			break
	var words := base.split("_", false)
	var pretty_words: Array[String] = []
	for word in words:
		pretty_words.append(String(word).capitalize())
	return " ".join(pretty_words)


func _demo_is_still_playing() -> bool:
	if active_demo == null:
		return false
	if active_demo.has_method("is_playing"):
		return bool(active_demo.call("is_playing"))
	return false


func _suppress_demo_caption_labels(scene_root: Node) -> void:
	if scene_root == null:
		return
	for child in scene_root.get_children():
		if child is Label:
			var label := child as Label
			# Most demo-local overlays use a top-left caption label around (16, 12).
			if label.position.x <= 24.0 and label.position.y <= 20.0:
				label.visible = false
