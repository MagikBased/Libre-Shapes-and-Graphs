class_name PortDemoCatalog
extends RefCounted

const VISUAL_2D_DEMOS: Array[String] = [
	"res://Scenes/port_demos/animation_queue_demo.tscn",
	"res://Scenes/port_demos/animate_builder_demo.tscn",
	"res://Scenes/port_demos/text_and_tex_demo.tscn",
	"res://Scenes/port_demos/show_creation_demo.tscn",
	"res://Scenes/port_demos/fade_demo.tscn",
	"res://Scenes/port_demos/fade_transform_demo.tscn",
	"res://Scenes/port_demos/indication_demo.tscn",
	"res://Scenes/port_demos/lagged_group_demo.tscn",
	"res://Scenes/port_demos/timeline_controls_demo.tscn",
	"res://Scenes/port_demos/transform_demo.tscn",
	"res://Scenes/port_demos/transform_matching_shapes_demo.tscn",
	"res://Scenes/port_demos/graph_demo.tscn",
	"res://Scenes/port_demos/implicit_function_demo.tscn",
	"res://Scenes/port_demos/example_graph_scene_port.tscn",
	"res://Scenes/port_demos/composition_demo.tscn",
	"res://Scenes/port_demos/updater_graph_demo.tscn",
	"res://Scenes/port_demos/value_tracker_demo.tscn",
	"res://Scenes/port_demos/advanced_parity_demo.tscn",
	"res://Scenes/port_demos/example_coordinate_system_port.tscn",
	"res://Scenes/port_demos/morph_and_smooth_demo.tscn",
	"res://Scenes/port_demos/play_semantics_map_demo.tscn",
	"res://Scenes/port_demos/camera_framing_demo.tscn",
	"res://Scenes/port_demos/math_tex_parity_demo.tscn",
	"res://Scenes/port_demos/decimal_number_parity_demo.tscn",
	"res://Scenes/port_demos/number_line_parity_demo.tscn",
	"res://Scenes/port_demos/angle_parity_demo.tscn",
	"res://Scenes/port_demos/group_layout_parity_demo.tscn",
	"res://Scenes/port_demos/surrounding_rectangle_parity_demo.tscn",
	"res://Scenes/port_demos/brace_parity_demo.tscn",
	"res://Scenes/port_demos/mixed_mobject_parity_demo.tscn",
	"res://Scenes/port_demos/dynamic_helpers_demo.tscn",
	"res://Scenes/port_demos/path_follow_parity_demo.tscn",
	"res://Scenes/port_demos/animation_expansion_demo.tscn",
	"res://Scenes/port_demos/advanced_graphing_upgrade_demo.tscn",
]

const VISUAL_3D_DEMOS: Array[String] = [
	"res://Scenes/port_demos/surface_3d_demo.tscn",
	"res://Scenes/port_demos/three_d_parity_demo.tscn",
]

const TOOL_DEMOS: Array[String] = [
	"res://Scenes/port_demos/port_demos_index.tscn",
	"res://Scenes/port_demos/port_demos_runner.tscn",
	"res://Scenes/port_demos/port_demos_smoke_check.tscn",
	"res://Scenes/port_demos/render_export_workflow_helper.tscn",
	"res://Scenes/port_demos/phase6_coverage_report.tscn",
]


static func get_visual_demos() -> Array[String]:
	var paths := VISUAL_2D_DEMOS.duplicate()
	paths.append_array(VISUAL_3D_DEMOS)
	return paths


static func get_index_demos() -> Array[String]:
	var paths := get_visual_demos()
	paths.append_array(TOOL_DEMOS.filter(func(p): return p != "res://Scenes/port_demos/port_demos_index.tscn"))
	return paths


static func get_runner_demos() -> Array[String]:
	return VISUAL_2D_DEMOS.duplicate()


static func get_smoke_demos() -> Array[String]:
	return get_visual_demos()
