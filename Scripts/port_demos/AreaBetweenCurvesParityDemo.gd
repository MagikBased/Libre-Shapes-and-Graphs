# Demo: AreaBetweenCurvesParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var sin_plot: FunctionPlot2D
var cos_plot: FunctionPlot2D
var band: PortAreaBetweenCurves2D
var tracker: PortValueTracker
var info_label: Label
var _last_x: float = 9999.0


func _ready() -> void:
	_create_caption("Phase 6 area-between-curves parity: dynamic fill between two graph functions")

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
	sin_plot.sample_count = 280
	sin_plot.render_mode = &"smooth"
	sin_plot.color = Color(0.34, 0.84, 1.0, 0.9)
	sin_plot.stroke_width = 2.8
	sin_plot.position = axes.position
	add_child(sin_plot)

	cos_plot = FunctionPlot2D.new()
	cos_plot.axes = axes
	cos_plot.function_name = &"cos"
	cos_plot.sample_count = 280
	cos_plot.render_mode = &"smooth"
	cos_plot.color = Color(1.0, 0.72, 0.34, 0.9)
	cos_plot.stroke_width = 2.8
	cos_plot.position = axes.position
	add_child(cos_plot)

	band = PortAreaBetweenCurves2D.new()
	band.axes = axes
	band.top_graph = sin_plot
	band.bottom_graph = cos_plot
	band.position = axes.position
	band.x_min_value = -4.5
	band.x_max_value = -1.4
	band.sample_count = 180
	band.color = Color(0.56, 0.9, 0.66, 0.9)
	band.fill_alpha = 0.25
	band.recompute_polygon()
	add_child(band)

	tracker = PortValueTracker.new(-1.4)
	add_child(tracker)
	_last_x = tracker.get_value()

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play_group([
		PortShowCreation.new(sin_plot, 1.1, &"smooth"),
		PortShowCreation.new(cos_plot, 1.1, &"smooth"),
		PortFadeIn.new(band, 0.5, &"smooth"),
	])
	play_sequence([
		PortSetValue.new(tracker, 2.7, 1.35, &"smooth"),
		PortSetValue.new(tracker, 5.2, 1.1, &"smooth"),
		PortSetValue.new(tracker, -0.8, 1.55, &"there_and_back_with_pause"),
	])


func _process(_delta: float) -> void:
	if tracker == null or band == null:
		return
	var x: float = tracker.get_value()
	if absf(x - _last_x) >= 0.015:
		band.x_max_value = x
		band.recompute_polygon()
		_last_x = x

	var area_estimate: float = band.approximate_area(320)
	info_label.text = "x_range=[%.2f, %.2f]  approx integral(sin-cos)=%.3f" % [band.x_min_value, x, area_estimate]


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
