# Demo: AutocorrelationParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var corr_plot: PortAutocorrelationPlot2D
var parameter_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 autocorrelation parity: lag-correlation bars from logistic-map sequence")

	var lag_cap: int = 120
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(lag_cap)
	axes.y_min = -1.05
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = PortValueTracker.new(3.82)
	add_child(parameter_tracker)

	corr_plot = PortAutocorrelationPlot2D.new()
	corr_plot.axes = axes
	corr_plot.position = axes.position
	corr_plot.map_callable = Callable(self, "_logistic_map")
	corr_plot.parameter_value = parameter_tracker.get_value()
	corr_plot.initial_value = 0.239
	corr_plot.settle_iterations = 140
	corr_plot.sample_count = 420
	corr_plot.max_lag = lag_cap
	corr_plot.bar_width_scale = 0.84
	corr_plot.alpha = 0.88
	corr_plot.auto_update = false
	corr_plot.rebuild()
	add_child(corr_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortFadeIn.new(corr_plot, 0.5, &"smooth"))
	play_sequence([
		PortSetValue.new(parameter_tracker, 3.69, 1.2, &"smooth"),
		PortSetValue.new(parameter_tracker, 3.91, 1.3, &"there_and_back_with_pause"),
		PortSetValue.new(parameter_tracker, 3.79, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if corr_plot == null:
		return
	corr_plot.parameter_value = parameter_tracker.get_value()
	corr_plot.rebuild()
	info_label.text = "r=%.3f  lags=%d  normalized autocorrelation C(k)" % [
		parameter_tracker.get_value(),
		corr_plot.lag_count(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
