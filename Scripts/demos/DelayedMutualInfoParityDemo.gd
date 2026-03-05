# Demo: DelayedMutualInfoParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var mi_plot: LsgDelayedMutualInfo2D
var parameter_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 delayed-mutual-information parity: information decay vs delay")

	var tau_max: int = 80
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(tau_max)
	axes.y_min = 0.0
	axes.y_max = 4.0
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	mi_plot = GShapes.DelayedMutualInfo2D.new()
	mi_plot.axes = axes
	mi_plot.position = axes.position
	mi_plot.map_callable = Callable(self, "_logistic_map")
	mi_plot.parameter_value = parameter_tracker.get_value()
	mi_plot.initial_value = 0.238
	mi_plot.settle_iterations = 140
	mi_plot.sample_count = 560
	mi_plot.max_delay = tau_max
	mi_plot.histogram_bins = 24
	mi_plot.bar_width_scale = 0.86
	mi_plot.alpha = 0.88
	mi_plot.auto_update = false
	mi_plot.rebuild()
	add_child(mi_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(mi_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.72, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if mi_plot == null:
		return
	mi_plot.parameter_value = parameter_tracker.get_value()
	mi_plot.rebuild()
	info_label.text = "r=%.3f  delays=%d  peak MI=%.3f bits" % [
		parameter_tracker.get_value(),
		mi_plot.delay_count(),
		mi_plot.peak_mi(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

