# Demo: FirstReturnTimeParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var return_plot: GShapesFirstReturnTime2D
var parameter_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 first-return-time parity: return-delay distribution to a target interval")

	var kmax: int = 180
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(kmax)
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	return_plot = GShapes.FirstReturnTime2D.new()
	return_plot.axes = axes
	return_plot.position = axes.position
	return_plot.map_callable = Callable(self, "_logistic_map")
	return_plot.parameter_value = parameter_tracker.get_value()
	return_plot.seed_min = 0.0
	return_plot.seed_max = 1.0
	return_plot.seed_samples = 280
	return_plot.target_min = 0.45
	return_plot.target_max = 0.55
	return_plot.max_iterations = kmax
	return_plot.bar_width_scale = 0.84
	return_plot.alpha = 0.88
	return_plot.auto_update = false
	return_plot.rebuild()
	add_child(return_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(return_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if return_plot == null:
		return
	return_plot.parameter_value = parameter_tracker.get_value()
	return_plot.rebuild()
	info_label.text = "r=%.3f  bins=%d  peak count=%d  target=[%.2f, %.2f]" % [
		parameter_tracker.get_value(),
		return_plot.bin_count(),
		return_plot.peak_count(),
		return_plot.target_min,
		return_plot.target_max,
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




