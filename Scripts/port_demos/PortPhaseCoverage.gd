class_name PortPhaseCoverage
extends RefCounted

const VISUAL_PHASE_TAGS: Array[String] = ["P6.1", "P6.2", "P6.3", "P6.4", "P6.5", "P6.6", "P6.10", "P6.11", "P6.12", "P6.13", "P6.14", "P6.15", "P6.16", "P6.17", "P6.18", "P6.19", "P6.20", "P6.21", "P6.22", "P6.23", "P6.24", "P6.25", "P6.26", "P6.27", "P6.28", "P6.29", "P6.30", "P6.31", "P6.32", "P6.33", "P6.34", "P6.35", "P6.36", "P6.37", "P6.38", "P6.39", "P6.40", "P6.41", "P6.42", "P6.43", "P6.44", "P6.45", "P6.46", "P6.47", "P6.48", "P6.49"]
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
	"P6.18",
	"P6.19",
	"P6.20",
	"P6.21",
	"P6.22",
	"P6.23",
	"P6.24",
	"P6.25",
	"P6.26",
	"P6.27",
	"P6.28",
	"P6.29",
	"P6.30",
	"P6.31",
	"P6.32",
	"P6.33",
	"P6.34",
	"P6.35",
	"P6.36",
	"P6.37",
	"P6.38",
	"P6.39",
	"P6.40",
	"P6.41",
	"P6.42",
	"P6.43",
	"P6.44",
	"P6.45",
	"P6.46",
	"P6.47",
	"P6.48",
	"P6.49",
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
	if path.ends_with("dashed_line_parity_demo.tscn"):
		return "P6.18"
	if path.ends_with("arrow_vector_parity_demo.tscn"):
		return "P6.19"
	if path.ends_with("vector_field_parity_demo.tscn"):
		return "P6.20"
	if path.ends_with("parametric_curve_parity_demo.tscn"):
		return "P6.21"
	if path.ends_with("stream_lines_parity_demo.tscn"):
		return "P6.22"
	if path.ends_with("polar_plot_parity_demo.tscn"):
		return "P6.23"
	if path.ends_with("polar_plane_parity_demo.tscn"):
		return "P6.24"
	if path.ends_with("complex_plane_parity_demo.tscn"):
		return "P6.25"
	if path.ends_with("flow_particles_parity_demo.tscn"):
		return "P6.26"
	if path.ends_with("conformal_grid_parity_demo.tscn"):
		return "P6.27"
	if path.ends_with("complex_function_parity_demo.tscn"):
		return "P6.28"
	if path.ends_with("fourier_curve_parity_demo.tscn"):
		return "P6.29"
	if path.ends_with("epicycle_chain_parity_demo.tscn"):
		return "P6.30"
	if path.ends_with("curvature_comb_parity_demo.tscn"):
		return "P6.31"
	if path.ends_with("arc_length_markers_parity_demo.tscn"):
		return "P6.32"
	if path.ends_with("tangent_frame_parity_demo.tscn"):
		return "P6.33"
	if path.ends_with("curve_window_parity_demo.tscn"):
		return "P6.34"
	if path.ends_with("normal_offset_parity_demo.tscn"):
		return "P6.35"
	if path.ends_with("osculating_circle_parity_demo.tscn"):
		return "P6.36"
	if path.ends_with("curve_intersections_parity_demo.tscn"):
		return "P6.37"
	if path.ends_with("nearest_point_parity_demo.tscn"):
		return "P6.38"
	if path.ends_with("riemann_rectangles_parity_demo.tscn"):
		return "P6.39"
	if path.ends_with("graph_label_follower_parity_demo.tscn"):
		return "P6.40"
	if path.ends_with("area_between_curves_parity_demo.tscn"):
		return "P6.41"
	if path.ends_with("derivative_plot_parity_demo.tscn"):
		return "P6.42"
	if path.ends_with("integral_plot_parity_demo.tscn"):
		return "P6.43"
	if path.ends_with("secant_slope_group_parity_demo.tscn"):
		return "P6.44"
	if path.ends_with("graph_roots_parity_demo.tscn"):
		return "P6.45"
	if path.ends_with("graph_extrema_parity_demo.tscn"):
		return "P6.46"
	if path.ends_with("graph_inflection_parity_demo.tscn"):
		return "P6.47"
	if path.ends_with("newton_iteration_parity_demo.tscn"):
		return "P6.48"
	if path.ends_with("bisection_iteration_parity_demo.tscn"):
		return "P6.49"
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
