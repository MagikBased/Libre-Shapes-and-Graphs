# Demo: AdvancedGraphingUpgradeDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var plot: FunctionPlot2D
var area: GShapesAreaUnderCurve2D
var guides: GShapesGraphGuideLines2D
var tangent_line: GShapesPolylineMobject
var secant_line: GShapesPolylineMobject
var dot: Circle
var x_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 advanced graphing: area fill + tangent/secant + dynamic guides")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 100.0)
	axes.viewport_size = Vector2(1000.0, 560.0)
	axes.x_min = -4.0
	axes.x_max = 8.0
	axes.y_min = -3.0
	axes.y_max = 7.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	plot = FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = &"cubic"
	plot.render_mode = &"smooth"
	plot.sample_count = 260
	plot.color = Color.DEEP_SKY_BLUE
	plot.stroke_width = 3.0
	plot.position = axes.position
	plot.set_draw_progress(0.0)
	add_child(plot)

	area = GShapes.AreaUnderCurve2D.new()
	area.axes = axes
	area.graph = plot
	area.x_min_value = -1.8
	area.x_max_value = 2.8
	area.baseline_y = -2.0
	area.color = Color(0.2, 0.85, 0.55)
	area.fill_alpha = 0.22
	area.position = axes.position
	area.set_draw_progress(0.0)
	area.recompute_polygon()
	add_child(area)

	guides = GShapes.GraphGuideLines2D.new()
	guides.axes = axes
	guides.color = Color(0.95, 0.85, 0.2, 0.9)
	guides.stroke_width = 2.0
	guides.position = axes.position
	guides.set_draw_progress(0.0)
	add_child(guides)

	tangent_line = GShapes.PolylineMobject.new()
	tangent_line.color = Color.GOLD
	tangent_line.stroke_width = 2.4
	tangent_line.position = axes.position
	tangent_line.set_draw_progress(0.0)
	add_child(tangent_line)

	secant_line = GShapes.PolylineMobject.new()
	secant_line.color = Color.MEDIUM_SPRING_GREEN
	secant_line.stroke_width = 2.4
	secant_line.position = axes.position
	secant_line.set_draw_progress(0.0)
	add_child(secant_line)

	dot = Circle.new()
	dot.size = Vector2(18.0, 18.0)
	dot.color = Color.ORANGE_RED
	add_child(dot)

	x_tracker = GShapes.ValueTracker.new(-1.5)
	add_child(x_tracker)
	dot.add_updater(_update_marker_system)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.86, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(plot, 1.2, &"smooth"))
	play_group([
		GShapes.ShowCreation.new(area, 1.0, &"smooth"),
		GShapes.ShowCreation.new(guides, 1.0, &"smooth"),
		GShapes.ShowCreation.new(tangent_line, 1.0, &"smooth"),
		GShapes.ShowCreation.new(secant_line, 1.0, &"smooth"),
		GShapes.FadeIn.new(dot, 0.3, &"smooth"),
	])
	play_sequence([
		GShapes.SetValue.new(x_tracker, 4.5, 1.6, &"smooth"),
		GShapes.SetValue.new(x_tracker, 0.2, 1.4, &"there_and_back_with_pause"),
	])


func _update_marker_system(target: GShapesObject2D, _delta: float) -> void:
	var x := x_tracker.get_value()
	var y := plot.eval_y(x)
	target.position = axes.to_global(axes.c2p(x, y))

	guides.set_graph_point(Vector2(x, y))
	var secant_end := minf(axes.x_max - 0.1, x + 1.4)
	tangent_line.points = axes.get_tangent_line_points(plot, x, 2.4)
	secant_line.points = axes.get_secant_line_points(plot, x, secant_end)

	var slope := plot.get_slope_at_x(x)
	info_label.text = "x=%.2f  y=%.2f  slope=%.2f" % [x, y, slope]


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




