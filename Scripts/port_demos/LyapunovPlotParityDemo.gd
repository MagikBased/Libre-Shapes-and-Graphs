# Demo: LyapunovPlotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var lyapunov_plot: PortLyapunovPlot2D
var seed_tracker: PortValueTracker
var zero_line: PortPolylineMobject
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 Lyapunov parity: logistic-map exponent sweep vs parameter r")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 2.5
	axes.x_max = 4.0
	axes.y_min = -2.2
	axes.y_max = 1.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	seed_tracker = PortValueTracker.new(0.37)
	add_child(seed_tracker)

	zero_line = PortPolylineMobject.new()
	zero_line.position = axes.position
	zero_line.color = Color(0.9, 0.95, 1.0, 0.45)
	zero_line.stroke_width = 1.4
	zero_line.points = PackedVector2Array([
		axes.c2p(axes.x_min, 0.0),
		axes.c2p(axes.x_max, 0.0),
	])
	add_child(zero_line)

	lyapunov_plot = PortLyapunovPlot2D.new()
	lyapunov_plot.axes = axes
	lyapunov_plot.position = axes.position
	lyapunov_plot.parameter_min = 2.5
	lyapunov_plot.parameter_max = 4.0
	lyapunov_plot.parameter_samples = 220
	lyapunov_plot.initial_value = seed_tracker.get_value()
	lyapunov_plot.settle_iterations = 80
	lyapunov_plot.measure_iterations = 120
	lyapunov_plot.color = Color(1.0, 0.84, 0.36, 0.95)
	lyapunov_plot.stroke_width = 2.2
	lyapunov_plot.map_callable = Callable(self, "_logistic_map")
	lyapunov_plot.derivative_callable = Callable(self, "_logistic_derivative")
	lyapunov_plot.auto_update = false
	lyapunov_plot.rebuild_curve()
	lyapunov_plot.set_draw_progress(0.0)
	add_child(lyapunov_plot)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortShowCreation.new(lyapunov_plot, 1.1, &"smooth"))
	play_sequence([
		PortSetValue.new(seed_tracker, 0.62, 1.15, &"smooth"),
		PortSetValue.new(seed_tracker, 0.21, 1.25, &"there_and_back_with_pause"),
		PortSetValue.new(seed_tracker, 0.44, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if lyapunov_plot == null:
		return
	lyapunov_plot.initial_value = seed_tracker.get_value()
	lyapunov_plot.rebuild_curve()
	info_label.text = "seed=%.3f  logistic: lambda(r)>0 => chaotic regime" % [
		seed_tracker.get_value(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _logistic_derivative(x: float, r: float) -> float:
	return r * (1.0 - 2.0 * x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
