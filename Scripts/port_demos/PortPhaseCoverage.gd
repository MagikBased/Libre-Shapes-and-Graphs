class_name PortPhaseCoverage
extends RefCounted

const VISUAL_PHASE_TAGS: Array[String] = ["P6.1", "P6.2", "P6.3", "P6.4", "P6.5", "P6.6", "P6.10", "P6.11", "P6.12", "P6.13", "P6.14", "P6.15", "P6.16", "P6.17"]
const TOOLING_PHASE_TAGS: Array[String] = ["P6.7", "P6.8", "P6.9"]
const FULL_PHASE_TAGS: Array[String] = [
	"P6.1",
	"P6.2",
	"P6.3",
	"P6.4",
	"P6.5",
	"P6.6",
	"P6.7",
	"P6.8",
	"P6.9",
	"P6.10",
	"P6.11",
	"P6.12",
	"P6.13",
	"P6.14",
	"P6.15",
	"P6.16",
	"P6.17",
]

static func wanted_phase_tags(include_tooling: bool = false) -> Array[String]:
	if include_tooling:
		return FULL_PHASE_TAGS.duplicate()
	return VISUAL_PHASE_TAGS.duplicate()


static func phase_tag_for_scene(path: String) -> String:
	if path.ends_with("math_tex_parity_demo.tscn"):
		return "P6.1"
	if path.ends_with("mixed_mobject_parity_demo.tscn"):
		return "P6.2"
	if path.ends_with("animation_expansion_demo.tscn"):
		return "P6.3"
	if path.ends_with("three_d_parity_demo.tscn"):
		return "P6.4"
	if path.ends_with("render_export_workflow_helper.tscn"):
		return "P6.5"
	if path.ends_with("advanced_graphing_upgrade_demo.tscn"):
		return "P6.6"
	if path.ends_with("dynamic_helpers_demo.tscn"):
		return "P6.10"
	if path.ends_with("path_follow_parity_demo.tscn"):
		return "P6.11"
	if path.ends_with("decimal_number_parity_demo.tscn"):
		return "P6.12"
	if path.ends_with("group_layout_parity_demo.tscn"):
		return "P6.13"
	if path.ends_with("surrounding_rectangle_parity_demo.tscn"):
		return "P6.14"
	if path.ends_with("brace_parity_demo.tscn"):
		return "P6.15"
	if path.ends_with("number_line_parity_demo.tscn"):
		return "P6.16"
	if path.ends_with("angle_parity_demo.tscn"):
		return "P6.17"
	if path.ends_with("port_demos_runner.tscn"):
		return "P6.7"
	if path.ends_with("phase6_coverage_report.tscn"):
		return "P6.8"
	if path.ends_with("port_demos_smoke_check.tscn"):
		return "P6.9"
	return "base"


static func coverage_ratio(phase_counts: Dictionary, include_tooling: bool = false) -> Vector2i:
	var wanted := wanted_phase_tags(include_tooling)
	var hit := 0
	for p in wanted:
		if int(phase_counts.get(p, 0)) > 0:
			hit += 1
	return Vector2i(hit, wanted.size())
