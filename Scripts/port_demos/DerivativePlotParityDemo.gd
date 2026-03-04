# Demo: DerivativePlotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var base_plot: FunctionPlot2D
var derivative_plot: PortDerivativePlot2D
var x_tracker: PortValueTracker
var marker: Circle
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 derivative-plot parity: numerical derivative overlay with tracked slope readout")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -4.5
	axes.x_max = 7.5
	axes.y_min = -4.5
	axes.y_max = 4.5
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	base_plot = FunctionPlot2D.new()
	base_plot.axes = axes
	base_plot.function_name = &"cubic"
	base_plot.sample_count = 280
	base_plot.render_mode = &"smooth"
	base_plot.color = Color(0.3, 0.82, 1.0, 0.9)
	base_plot.stroke_width = 2.8
	base_plot.position = axes.position
	add_child(base_plot)
	base_plot.set_draw_progress(0.0)

	derivative_plot = PortDerivativePlot2D.new()
	derivative_plot.axes = axes
	derivative_plot.source_graph = base_plot
	derivative_plot.sample_count = 260
	derivative_plot.derivative_epsilon = 0.003
	derivative_plot.color = Color(1.0, 0.68, 0.3, 0.92)
	derivative_plot.stroke_width = 2.5
	derivative_plot.auto_update = false
	derivative_plot.position = axes.position
	derivative_plot.set_draw_progress(0.0)
	add_child(derivative_plot)

	x_tracker = PortValueTracker.new(-3.4)
	add_child(x_tracker)

	marker = Circle.new()
	marker.size = Vector2(14.0, 14.0)
	marker.color = Color(1.0, 0.78, 0.36, 0.96)
	add_child(marker)
	marker.add_updater(_update_marker)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play_group([
		PortShowCreation.new(base_plot, 1.2, &"smooth"),
		PortShowCreation.new(derivative_plot, 1.2, &"smooth"),
		PortFadeIn.new(marker, 0.4, &"smooth"),
	])
	play_sequence([
		PortSetValue.new(x_tracker, 6.3, 1.6, &"smooth"),
		PortSetValue.new(x_tracker, -1.0, 1.2, &"smooth"),
		PortSetValue.new(x_tracker, 4.2, 1.0, &"smooth"),
	])


func _update_marker(target: PortObject2D, _delta: float) -> void:
	var x: float = x_tracker.get_value()
	var y_deriv: float = derivative_plot.eval_derivative(x)
	target.position = axes.to_global(axes.c2p(x, y_deriv))
	info_label.text = "x=%.2f  f(x)=%.2f  f'(x)=%.2f" % [x, base_plot.eval_y(x), y_deriv]


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
