# Demo: MorphAndSmoothDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var poly_source: Polygon2D
var poly_target: Polygon2D
var axes: GraphAxes2D
var smooth_plot: FunctionPlot2D
var smooth_label: Label


func _ready() -> void:
	_create_caption("Optional parity demo: polygon morph + smooth plot + auto labels")

	poly_source = _make_polygon(
		PackedVector2Array([
			Vector2(0.0, -60.0),
			Vector2(56.0, 46.0),
			Vector2(-56.0, 46.0),
		]),
		Vector2(220.0, 220.0),
		Color.ORANGE_RED
	)

	poly_target = _make_polygon(
		PackedVector2Array([
			Vector2(0.0, -64.0),
			Vector2(24.0, -24.0),
			Vector2(66.0, -20.0),
			Vector2(34.0, 12.0),
			Vector2(44.0, 60.0),
			Vector2(0.0, 34.0),
			Vector2(-44.0, 60.0),
			Vector2(-34.0, 12.0),
			Vector2(-66.0, -20.0),
			Vector2(-24.0, -24.0),
		]),
		Vector2(220.0, 220.0),
		Color.GOLD
	)

	axes = GraphAxes2D.new()
	axes.position = Vector2(380.0, 90.0)
	axes.viewport_size = Vector2(730.0, 560.0)
	axes.x_min = -4.0
	axes.x_max = 10.0
	axes.y_min = -2.0
	axes.y_max = 6.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	smooth_plot = FunctionPlot2D.new()
	smooth_plot.axes = axes
	smooth_plot.function_name = &"cubic"
	smooth_plot.render_mode = &"smooth"
	smooth_plot.sample_count = 140
	smooth_plot.color = Color.DEEP_SKY_BLUE
	smooth_plot.stroke_width = 3.0
	smooth_plot.position = axes.position
	add_child(smooth_plot)
	smooth_plot.set_draw_progress(0.0)

	smooth_label = axes.get_graph_label(
		smooth_plot,
		"smooth cubic",
		9.5,
		18,
		Color.DEEP_SKY_BLUE,
		&"auto"
	)
	smooth_label.position += axes.position
	smooth_label.modulate.a = 0.0
	add_child(smooth_label)

	play_group([
		GShapes.ShowCreation.new(smooth_plot, 1.2, &"smooth"),
		GShapes.MorphTransform.new(poly_source, poly_target, 1.5, &"smooth"),
	])
	smooth_label.modulate.a = 1.0


func _make_polygon(points: PackedVector2Array, pos: Vector2, fill_color: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.polygon = points
	poly.position = pos
	poly.color = fill_color
	add_child(poly)
	return poly


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

