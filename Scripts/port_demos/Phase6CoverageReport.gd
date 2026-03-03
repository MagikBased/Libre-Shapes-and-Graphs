# Demo: Phase6CoverageReport
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Node2D

var title_label: Label
var summary_label: Label
var details_label: Label


func _ready() -> void:
	title_label = Label.new()
	title_label.text = "Phase 6 Coverage Report"
	title_label.position = Vector2(20.0, 16.0)
	title_label.add_theme_font_size_override("font_size", 30)
	add_child(title_label)

	summary_label = Label.new()
	summary_label.position = Vector2(20.0, 62.0)
	summary_label.add_theme_font_size_override("font_size", 18)
	add_child(summary_label)

	details_label = Label.new()
	details_label.position = Vector2(20.0, 98.0)
	details_label.add_theme_font_size_override("font_size", 15)
	add_child(details_label)

	_build_report()


func _build_report() -> void:
	var all_scenes := PortDemoCatalog.get_visual_demos()
	all_scenes.append_array(PortDemoCatalog.TOOL_DEMOS)

	var phase_counts: Dictionary = {}
	var missing_resources: Array[String] = []
	for scene_path in all_scenes:
		var phase := PortPhaseCoverage.phase_tag_for_scene(scene_path)
		phase_counts[phase] = int(phase_counts.get(phase, 0)) + 1
		if not ResourceLoader.exists(scene_path):
			missing_resources.append(scene_path)

	var ratio := PortPhaseCoverage.coverage_ratio(phase_counts, true)
	summary_label.text = "Coverage: phase6_full=%d/%d | visual=%d | tools=%d | missing=%d" % [
		ratio.x,
		ratio.y,
		PortDemoCatalog.get_visual_demos().size(),
		PortDemoCatalog.TOOL_DEMOS.size(),
		missing_resources.size(),
	]

	var lines: Array[String] = []
	var wanted := PortPhaseCoverage.wanted_phase_tags(true)
	for tag in wanted:
		lines.append("%s: %d scene(s)" % [tag, int(phase_counts.get(tag, 0))])

	if missing_resources.is_empty():
		lines.append("Missing resources: none")
	else:
		lines.append("Missing resources:")
		for p in missing_resources:
			lines.append("- %s" % p)

	details_label.text = "\n".join(lines)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()
