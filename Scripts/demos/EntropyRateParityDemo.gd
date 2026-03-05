# Demo: EntropyRateParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var rate_plot: GShapesEntropyRate2D
var parameter_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 entropy-rate parity: incremental block-entropy growth for symbolic dynamics")

	var kmax: int = 10
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 1.0
	axes.x_max = float(kmax)
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	rate_plot = GShapes.EntropyRate2D.new()
	rate_plot.axes = axes
	rate_plot.position = axes.position
	rate_plot.map_callable = Callable(self, "_logistic_map")
	rate_plot.parameter_value = parameter_tracker.get_value()
	rate_plot.initial_value = 0.244
	rate_plot.partition_value = 0.5
	rate_plot.settle_iterations = 140
	rate_plot.symbol_count = 760
	rate_plot.max_block_length = kmax
	rate_plot.bar_width_scale = 0.82
	rate_plot.alpha = 0.88
	rate_plot.auto_update = false
	rate_plot.rebuild()
	add_child(rate_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(rate_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if rate_plot == null:
		return
	rate_plot.parameter_value = parameter_tracker.get_value()
	rate_plot.rebuild()
	info_label.text = "r=%.3f  orders=%d  peak raw rate=%.3f bits" % [
		parameter_tracker.get_value(),
		rate_plot.order_count(),
		rate_plot.peak_rate(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




