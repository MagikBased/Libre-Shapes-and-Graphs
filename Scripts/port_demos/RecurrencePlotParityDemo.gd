# Demo: RecurrencePlotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var recurrence_plot: PortRecurrencePlot2D
var parameter_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 recurrence-plot parity: iterative-map time-series recurrence matrix")

	var n: int = 140
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(n - 1)
	axes.y_min = 0.0
	axes.y_max = float(n - 1)
	add_child(axes)
	axes.add_coordinate_labels(8, false)

	parameter_tracker = PortValueTracker.new(3.82)
	add_child(parameter_tracker)

	recurrence_plot = PortRecurrencePlot2D.new()
	recurrence_plot.axes = axes
	recurrence_plot.position = axes.position
	recurrence_plot.map_callable = Callable(self, "_logistic_map")
	recurrence_plot.parameter_value = parameter_tracker.get_value()
	recurrence_plot.initial_value = 0.217
	recurrence_plot.settle_iterations = 140
	recurrence_plot.sequence_length = n
	recurrence_plot.threshold = 0.006
	recurrence_plot.point_radius = 1.0
	recurrence_plot.alpha = 0.86
	recurrence_plot.auto_update = false
	recurrence_plot.rebuild()
	add_child(recurrence_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortFadeIn.new(recurrence_plot, 0.5, &"smooth"))
	play_sequence([
		PortSetValue.new(parameter_tracker, 3.70, 1.2, &"smooth"),
		PortSetValue.new(parameter_tracker, 3.90, 1.3, &"there_and_back_with_pause"),
		PortSetValue.new(parameter_tracker, 3.80, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if recurrence_plot == null:
		return
	recurrence_plot.parameter_value = parameter_tracker.get_value()
	recurrence_plot.rebuild()
	info_label.text = "r=%.3f  n=%d  eps=%.4f  points=%d" % [
		parameter_tracker.get_value(),
		recurrence_plot.sequence_length,
		recurrence_plot.threshold,
		recurrence_plot.point_count(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
