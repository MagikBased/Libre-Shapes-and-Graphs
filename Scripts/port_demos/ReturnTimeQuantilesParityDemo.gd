# Demo: ReturnTimeQuantilesParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var quantile_plot: PortReturnTimeQuantiles2D
var parameter_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 return-time quantiles parity: quantile profile of first-return delays")

	var q_count: int = 5
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 1.0
	axes.x_max = float(q_count)
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(7, false)

	parameter_tracker = PortValueTracker.new(3.85)
	add_child(parameter_tracker)

	quantile_plot = PortReturnTimeQuantiles2D.new()
	quantile_plot.axes = axes
	quantile_plot.position = axes.position
	quantile_plot.map_callable = Callable(self, "_logistic_map")
	quantile_plot.parameter_value = parameter_tracker.get_value()
	quantile_plot.seed_min = 0.0
	quantile_plot.seed_max = 1.0
	quantile_plot.seed_samples = 280
	quantile_plot.target_min = 0.45
	quantile_plot.target_max = 0.55
	quantile_plot.max_iterations = 180
	quantile_plot.quantiles = [0.1, 0.25, 0.5, 0.75, 0.9]
	quantile_plot.bar_width_scale = 0.78
	quantile_plot.alpha = 0.88
	quantile_plot.auto_update = false
	quantile_plot.rebuild()
	add_child(quantile_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortFadeIn.new(quantile_plot, 0.5, &"smooth"))
	play_sequence([
		PortSetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		PortSetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		PortSetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if quantile_plot == null:
		return
	quantile_plot.parameter_value = parameter_tracker.get_value()
	quantile_plot.rebuild()
	info_label.text = "r=%.3f  quantiles=%d  max raw return=%.1f" % [
		parameter_tracker.get_value(),
		quantile_plot.quantile_count(),
		quantile_plot.max_raw_value(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
