# Demo: OrbitDiagramParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var orbit: LsgOrbitDiagram2D
var seed_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 orbit-diagram parity: logistic map asymptotic orbit points vs parameter")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 2.5
	axes.x_max = 4.0
	axes.y_min = -0.05
	axes.y_max = 1.05
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	seed_tracker = GShapes.ValueTracker.new(0.37)
	add_child(seed_tracker)

	orbit = GShapes.OrbitDiagram2D.new()
	orbit.axes = axes
	orbit.position = axes.position
	orbit.parameter_min = 2.5
	orbit.parameter_max = 4.0
	orbit.parameter_samples = 220
	orbit.initial_value = seed_tracker.get_value()
	orbit.settle_iterations = 80
	orbit.sample_iterations = 34
	orbit.point_radius = 1.05
	orbit.point_color = Color(1.0, 0.84, 0.35, 0.86)
	orbit.map_callable = Callable(self, "_logistic_map")
	orbit.auto_update = false
	orbit.rebuild()
	add_child(orbit)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(orbit, 0.45, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(seed_tracker, 0.61, 1.1, &"smooth"),
		GShapes.SetValue.new(seed_tracker, 0.18, 1.25, &"there_and_back_with_pause"),
		GShapes.SetValue.new(seed_tracker, 0.42, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if orbit == null:
		return
	orbit.initial_value = seed_tracker.get_value()
	orbit.rebuild()
	info_label.text = "seed=%.3f  points=%d  map=x_{n+1}=r*x_n*(1-x_n)" % [
		seed_tracker.get_value(),
		orbit.point_count(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

