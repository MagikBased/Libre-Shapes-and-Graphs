# Demo: IntegralPlotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var base_plot: FunctionPlot2D
var integral_plot: LsgIntegralPlot2D
var x_tracker: LsgValueTracker
var marker: Circle
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 integral-plot parity: numerical antiderivative overlay with tracked area readout")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -4.5
	axes.x_max = 7.5
	axes.y_min = -6.0
	axes.y_max = 6.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	base_plot = FunctionPlot2D.new()
	base_plot.axes = axes
	base_plot.function_name = &"sin"
	base_plot.sample_count = 280
	base_plot.render_mode = &"smooth"
	base_plot.color = Color(0.34, 0.84, 1.0, 0.9)
	base_plot.stroke_width = 2.8
	base_plot.position = axes.position
	add_child(base_plot)
	base_plot.set_draw_progress(0.0)

	integral_plot = GShapes.IntegralPlot2D.new()
	integral_plot.axes = axes
	integral_plot.source_graph = base_plot
	integral_plot.integration_origin_x = 0.0
	integral_plot.sample_count = 260
	integral_plot.integration_steps = 28
	integral_plot.color = Color(1.0, 0.7, 0.33, 0.92)
	integral_plot.stroke_width = 2.5
	integral_plot.auto_update = false
	integral_plot.position = axes.position
	integral_plot.set_draw_progress(0.0)
	add_child(integral_plot)

	x_tracker = GShapes.ValueTracker.new(-3.8)
	add_child(x_tracker)

	marker = Circle.new()
	marker.size = Vector2(14.0, 14.0)
	marker.color = Color(1.0, 0.8, 0.38, 0.96)
	add_child(marker)
	marker.add_updater(_update_marker)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play_group([
		GShapes.ShowCreation.new(base_plot, 1.2, &"smooth"),
		GShapes.ShowCreation.new(integral_plot, 1.2, &"smooth"),
		GShapes.FadeIn.new(marker, 0.4, &"smooth"),
	])
	play_sequence([
		GShapes.SetValue.new(x_tracker, 6.4, 1.7, &"smooth"),
		GShapes.SetValue.new(x_tracker, -2.0, 1.25, &"smooth"),
		GShapes.SetValue.new(x_tracker, 3.2, 1.0, &"smooth"),
	])


func _update_marker(target: LsgObject2D, _delta: float) -> void:
	var x: float = x_tracker.get_value()
	var integral_value: float = integral_plot.eval_integral(x)
	target.position = axes.to_global(axes.c2p(x, integral_value))
	info_label.text = "x=%.2f  f(x)=%.2f  F(x)=integral_0_to_x f(t)dt = %.3f" % [x, base_plot.eval_y(x), integral_value]


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

