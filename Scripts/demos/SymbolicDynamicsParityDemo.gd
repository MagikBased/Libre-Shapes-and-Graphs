# Demo: SymbolicDynamicsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var symbolic_plot: GShapesSymbolicDynamics2D
var parameter_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 symbolic-dynamics parity: binary itinerary sequence from logistic map")

	var n: int = 180
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(n - 1)
	axes.y_min = -0.05
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(8, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	symbolic_plot = GShapes.SymbolicDynamics2D.new()
	symbolic_plot.axes = axes
	symbolic_plot.position = axes.position
	symbolic_plot.map_callable = Callable(self, "_logistic_map")
	symbolic_plot.parameter_value = parameter_tracker.get_value()
	symbolic_plot.initial_value = 0.237
	symbolic_plot.partition_value = 0.5
	symbolic_plot.settle_iterations = 140
	symbolic_plot.symbol_count = n
	symbolic_plot.bar_width_scale = 0.86
	symbolic_plot.alpha = 0.88
	symbolic_plot.auto_update = false
	symbolic_plot.rebuild()
	add_child(symbolic_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(symbolic_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.82, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if symbolic_plot == null:
		return
	symbolic_plot.parameter_value = parameter_tracker.get_value()
	symbolic_plot.rebuild()
	info_label.text = "r=%.3f  n=%d  ones=%d  zeros=%d  partition=%.2f" % [
		parameter_tracker.get_value(),
		symbolic_plot.symbol_total(),
		symbolic_plot.one_count(),
		symbolic_plot.symbol_total() - symbolic_plot.one_count(),
		symbolic_plot.partition_value,
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




