# Demo: BlockEntropyParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var entropy_plot: GShapesBlockEntropy2D
var parameter_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 block-entropy parity: binary-word entropy growth in symbolic dynamics")

	var k_max: int = 10
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 1.0
	axes.x_max = float(k_max)
	axes.y_min = 0.0
	axes.y_max = float(k_max)
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	entropy_plot = GShapes.BlockEntropy2D.new()
	entropy_plot.axes = axes
	entropy_plot.position = axes.position
	entropy_plot.map_callable = Callable(self, "_logistic_map")
	entropy_plot.parameter_value = parameter_tracker.get_value()
	entropy_plot.initial_value = 0.236
	entropy_plot.partition_value = 0.5
	entropy_plot.settle_iterations = 140
	entropy_plot.symbol_count = 640
	entropy_plot.max_block_length = k_max
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
	info_label.text = "r=%.3f  blocks=%d  peak H=%.3f bits" % [
		parameter_tracker.get_value(),
		entropy_plot.block_count(),
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




