# Demo: ConvergenceMapParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var conv_map: LsgConvergenceMap2D
var parameter_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 convergence-map parity: seed-to-terminal-state scan for logistic map")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 1.0
	axes.y_min = 0.0
	axes.y_max = 1.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	parameter_tracker = GShapes.ValueTracker.new(3.2)
	add_child(parameter_tracker)

	conv_map = GShapes.ConvergenceMap2D.new()
	conv_map.axes = axes
	conv_map.position = axes.position
	conv_map.map_callable = Callable(self, "_logistic_map")
	conv_map.parameter_value = parameter_tracker.get_value()
	conv_map.seed_min = 0.0
	conv_map.seed_max = 1.0
	conv_map.seed_samples = 320
	conv_map.iteration_count = 90
	conv_map.point_radius = 1.0
	conv_map.alpha = 0.88
	conv_map.auto_update = false
	conv_map.rebuild()
	add_child(conv_map)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(conv_map, 0.45, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.45, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.72, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.88, 1.25, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.56, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if conv_map == null:
		return
	conv_map.parameter_value = parameter_tracker.get_value()
	conv_map.rebuild()
	info_label.text = "r=%.3f  seeds=%d  map=x_{n+1}=r*x_n*(1-x_n)" % [
		parameter_tracker.get_value(),
		conv_map.point_count(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

