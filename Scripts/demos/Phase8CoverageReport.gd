# Demo: Phase8CoverageReport
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Node2D

var title_label: Label
var summary_label: Label
var details_label: Label


func _ready() -> void:
	title_label = Label.new()
	title_label.text = "Phase 8 Coverage Report"
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
	var all_scenes: Array[String] = GShapes.DemoCatalog.get_visual_demos()
	all_scenes.append_array(GShapes.DemoCatalog.TOOL_DEMOS)

	var phase8_counts: Dictionary = {}
	var missing_resources: Array[String] = []
	for scene_path in all_scenes:
		var phase8: String = GShapes.PhaseCoverage.phase8_tag_for_scene(scene_path)
		if phase8 != "base":
			phase8_counts[phase8] = int(phase8_counts.get(phase8, 0)) + 1
			if not ResourceLoader.exists(scene_path):
				missing_resources.append(scene_path)

	var visual_ratio: Vector2i = GShapes.PhaseCoverage.coverage_ratio_phase8(phase8_counts, false)
	var full_ratio: Vector2i = GShapes.PhaseCoverage.coverage_ratio_phase8(phase8_counts, true)
	summary_label.text = "Coverage: phase8_visual=%d/%d | phase8_full=%d/%d | missing=%d" % [
		visual_ratio.x,
		visual_ratio.y,
		full_ratio.x,
		full_ratio.y,
		missing_resources.size(),
	]

	var lines: Array[String] = []
	var wanted: Array[String] = GShapes.PhaseCoverage.wanted_phase8_tags(true)
	for tag in wanted:
		lines.append("%s: %d scene(s)" % [tag, int(phase8_counts.get(tag, 0))])

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


