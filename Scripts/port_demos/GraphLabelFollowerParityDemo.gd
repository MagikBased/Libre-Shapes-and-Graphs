# Demo: GraphLabelFollowerParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var sin_plot: FunctionPlot2D
var cos_plot: FunctionPlot2D
var sin_follower: PortGraphLabelFollower2D
var cos_follower: PortGraphLabelFollower2D
var tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 graph-label follower parity: dynamic curve labels with tracked x")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -2.6
	axes.y_max = 2.6
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	sin_plot = FunctionPlot2D.new()
	sin_plot.axes = axes
	sin_plot.function_name = &"sin"
	sin_plot.sample_count = 260
	sin_plot.render_mode = &"smooth"
	sin_plot.color = Color(0.36, 0.84, 1.0, 0.9)
	sin_plot.stroke_width = 2.8
	sin_plot.position = axes.position
	add_child(sin_plot)

	cos_plot = FunctionPlot2D.new()
	cos_plot.axes = axes
	cos_plot.function_name = &"cos"
	cos_plot.sample_count = 260
	cos_plot.render_mode = &"smooth"
	cos_plot.color = Color(1.0, 0.72, 0.32, 0.9)
	cos_plot.stroke_width = 2.8
	cos_plot.position = axes.position
	add_child(cos_plot)

	tracker = PortValueTracker.new(-4.2)
	add_child(tracker)

	sin_follower = PortGraphLabelFollower2D.new()
	sin_follower.axes = axes
	sin_follower.graph = sin_plot
	sin_follower.text = "sin(x)"
	sin_follower.text_color = sin_plot.color
	sin_follower.font_size = 19
	sin_follower.anchor = &"auto"
	sin_follower.normal_offset = -22.0
	sin_follower.x_callable = Callable(self, "_sample_x_sin")
	add_child(sin_follower)

	cos_follower = PortGraphLabelFollower2D.new()
	cos_follower.axes = axes
	cos_follower.graph = cos_plot
	cos_follower.text = "cos(x)"
	cos_follower.text_color = cos_plot.color
	cos_follower.font_size = 19
	cos_follower.anchor = &"auto"
	cos_follower.normal_offset = 22.0
	cos_follower.x_callable = Callable(self, "_sample_x_cos")
	add_child(cos_follower)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play_group([
		PortShowCreation.new(sin_plot, 1.2, &"smooth"),
		PortShowCreation.new(cos_plot, 1.2, &"smooth"),
		PortFadeIn.new(sin_follower, 0.5, &"smooth"),
		PortFadeIn.new(cos_follower, 0.5, &"smooth"),
	])
	play_sequence([
		PortSetValue.new(tracker, 4.8, 1.6, &"smooth"),
		PortSetValue.new(tracker, -5.0, 1.7, &"smooth"),
		PortSetValue.new(tracker, 1.8, 1.1, &"there_and_back_with_pause"),
	])


func _process(_delta: float) -> void:
	if tracker == null or sin_plot == null or cos_plot == null:
		return
	var x: float = tracker.get_value()
	info_label.text = "x=%.2f  sin=%.2f  cos=%.2f" % [x, sin_plot.eval_y(x), cos_plot.eval_y(x + 0.9)]


func _sample_x_sin() -> float:
	return tracker.get_value()


func _sample_x_cos() -> float:
	return tracker.get_value() + 0.9


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
