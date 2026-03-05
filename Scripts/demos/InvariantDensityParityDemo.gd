# Demo: InvariantDensityParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var density_plot: LsgInvariantDensity2D
var parameter_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 invariant-density parity: logistic-map stationary distribution histogram")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 1.0
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	parameter_tracker = GShapes.ValueTracker.new(3.72)
	add_child(parameter_tracker)

	density_plot = GShapes.InvariantDensity2D.new()
	density_plot.axes = axes
	density_plot.position = axes.position
	density_plot.map_callable = Callable(self, "_logistic_map")
	density_plot.parameter_value = parameter_tracker.get_value()
	density_plot.initial_value = 0.241
	density_plot.settle_iterations = 240
	density_plot.sample_iterations = 6200
	density_plot.bin_count = 120
	density_plot.normalize_to_peak = true
	density_plot.density_scale = 1.0
	density_plot.alpha = 0.88
	density_plot.auto_update = false
	density_plot.rebuild()
	add_child(density_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(density_plot, 0.45, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.87, 1.3, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.61, 1.2, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.76, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if density_plot == null:
		return
	density_plot.parameter_value = parameter_tracker.get_value()
	density_plot.rebuild()
	info_label.text = "r=%.3f  bins=%d  peak=%.3f  invariant density (normalized)" % [
		parameter_tracker.get_value(),
		density_plot.bar_count(),
		density_plot.peak_density(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

