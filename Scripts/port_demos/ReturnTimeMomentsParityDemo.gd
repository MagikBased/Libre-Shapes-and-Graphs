# Demo: ReturnTimeMomentsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var moments_plot: PortReturnTimeMoments2D
var parameter_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 return-time moments parity: normalized moments across return-time distribution")

	var mmax: int = 4
	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 1.0
	axes.x_max = float(mmax)
	axes.y_min = 0.0
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(6, false)

	parameter_tracker = PortValueTracker.new(3.85)
	add_child(parameter_tracker)

	moments_plot = PortReturnTimeMoments2D.new()
	moments_plot.axes = axes
	moments_plot.position = axes.position
	moments_plot.map_callable = Callable(self, "_logistic_map")
	moments_plot.parameter_value = parameter_tracker.get_value()
	moments_plot.seed_min = 0.0
	moments_plot.seed_max = 1.0
	moments_plot.seed_samples = 280
	moments_plot.target_min = 0.45
	moments_plot.target_max = 0.55
	moments_plot.max_iterations = 180
	moments_plot.max_moment_order = mmax
	moments_plot.bar_width_scale = 0.82
	moments_plot.alpha = 0.88
	moments_plot.auto_update = false
	moments_plot.rebuild()
	add_child(moments_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortFadeIn.new(moments_plot, 0.5, &"smooth"))
	play_sequence([
		PortSetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		PortSetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		PortSetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if moments_plot == null:
		return
	moments_plot.parameter_value = parameter_tracker.get_value()
	moments_plot.rebuild()
	info_label.text = "r=%.3f  orders=%d  peak raw moment=%.3f" % [
		parameter_tracker.get_value(),
		moments_plot.order_count(),
		moments_plot.peak_moment(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
