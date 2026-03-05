# Demo: ReturnTimeCDFParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var cdf_plot: GShapesReturnTimeCDF2D
var parameter_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 return-time CDF parity: cumulative first-return distribution")

	var kmax: int = 180
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = float(kmax)
	axes.y_min = 0.0
	axes.y_max = 1.0
	add_child(axes)
	axes.add_coordinate_labels(10, false)

	parameter_tracker = GShapes.ValueTracker.new(3.85)
	add_child(parameter_tracker)

	cdf_plot = GShapes.ReturnTimeCDF2D.new()
	cdf_plot.axes = axes
	cdf_plot.position = axes.position
	cdf_plot.map_callable = Callable(self, "_logistic_map")
	cdf_plot.parameter_value = parameter_tracker.get_value()
	cdf_plot.seed_min = 0.0
	cdf_plot.seed_max = 1.0
	cdf_plot.seed_samples = 280
	cdf_plot.target_min = 0.45
	cdf_plot.target_max = 0.55
	cdf_plot.max_iterations = kmax
	cdf_plot.stroke_width = 2.0
	cdf_plot.auto_update = false
	cdf_plot.rebuild()
	add_child(cdf_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(cdf_plot, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if cdf_plot == null:
		return
	cdf_plot.parameter_value = parameter_tracker.get_value()
	cdf_plot.rebuild()
	info_label.text = "r=%.3f  points=%d  eventual return fraction=%.3f" % [
		parameter_tracker.get_value(),
		cdf_plot.point_count(),
		cdf_plot.hit_fraction(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




