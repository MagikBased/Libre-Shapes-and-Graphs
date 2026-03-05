# Demo: PowerSpectrumParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var spectrum_plot: LsgPowerSpectrum2D
var parameter_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 power-spectrum parity: frequency content of logistic-map sequence")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 0.5
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(9, false)

	parameter_tracker = GShapes.ValueTracker.new(3.82)
	add_child(parameter_tracker)

	spectrum_plot = GShapes.PowerSpectrum2D.new()
	spectrum_plot.axes = axes
	spectrum_plot.position = axes.position
	spectrum_plot.map_callable = Callable(self, "_logistic_map")
	spectrum_plot.parameter_value = parameter_tracker.get_value()
	spectrum_plot.initial_value = 0.243
	spectrum_plot.settle_iterations = 140
	spectrum_plot.sample_count = 256
	spectrum_plot.max_bins = 96
	spectrum_plot.use_hann_window = true
	spectrum_plot.bar_width_scale = 0.9
	spectrum_plot.alpha = 0.88
	spectrum_plot.auto_update = false
	spectrum_plot.rebuild()
	add_child(spectrum_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(spectrum_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.69, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.91, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.80, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if spectrum_plot == null:
		return
	spectrum_plot.parameter_value = parameter_tracker.get_value()
	spectrum_plot.rebuild()
	info_label.text = "r=%.3f  bins=%d  peak(raw)=%.3f  normalized spectrum" % [
		parameter_tracker.get_value(),
		spectrum_plot.bin_count(),
		spectrum_plot.peak_power(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

