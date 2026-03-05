# Demo: PermutationEntropyParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var entropy_plot: LsgPermutationEntropy2D
var parameter_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 permutation-entropy parity: ordinal-pattern complexity across dimensions")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 2.0
	axes.x_max = 7.0
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(8, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	entropy_plot = GShapes.PermutationEntropy2D.new()
	entropy_plot.axes = axes
	entropy_plot.position = axes.position
	entropy_plot.map_callable = Callable(self, "_logistic_map")
	entropy_plot.parameter_value = parameter_tracker.get_value()
	entropy_plot.initial_value = 0.241
	entropy_plot.settle_iterations = 140
	entropy_plot.sample_count = 760
	entropy_plot.min_dimension = 2
	entropy_plot.max_dimension = 7
	entropy_plot.embedding_delay = 1
	entropy_plot.bar_width_scale = 0.82
	entropy_plot.alpha = 0.88
	entropy_plot.auto_update = false
	entropy_plot.rebuild()
	add_child(entropy_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(entropy_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if entropy_plot == null:
		return
	entropy_plot.parameter_value = parameter_tracker.get_value()
	entropy_plot.rebuild()
	info_label.text = "r=%.3f  dims=%d  peak normalized H=%.3f" % [
		parameter_tracker.get_value(),
		entropy_plot.dimension_count(),
		entropy_plot.peak_entropy(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

