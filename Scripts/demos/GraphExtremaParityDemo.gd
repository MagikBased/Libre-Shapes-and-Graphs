# Demo: GraphExtremaParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var curve: LsgParametricFunction2D
var extrema: LsgGraphExtrema2D
var phase_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 graph-extrema parity: dynamic local max/min markers on animated curve")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -3.2
	axes.y_max = 3.2
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	phase_tracker = GShapes.ValueTracker.new(0.0)
	add_child(phase_tracker)

	curve = GShapes.ParametricFunction2D.new()
	curve.position = axes.position
	curve.t_min = 0.0
	curve.t_max = 1.0
	curve.sample_count = 320
	curve.color = Color(0.34, 0.84, 1.0, 0.92)
	curve.stroke_width = 2.8
	curve.parametric_source = Callable(self, "_sample_curve_point")
	curve.rebuild_curve()
	curve.set_draw_progress(0.0)
	add_child(curve)

	extrema = GShapes.GraphExtrema2D.new()
	extrema.axes = axes
	extrema.position = axes.position
	extrema.x_min_value = axes.x_min
	extrema.x_max_value = axes.x_max
	extrema.sample_count = 280
	extrema.function_callable = Callable(self, "_eval_dynamic_function")
	extrema.show_labels = true
	extrema.auto_update = false
	add_child(extrema)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(curve, 1.2, &"smooth"))
	play(GShapes.FadeIn.new(extrema, 0.4, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(phase_tracker, 1.2, 1.4, &"smooth"),
		GShapes.SetValue.new(phase_tracker, -0.7, 1.35, &"there_and_back_with_pause"),
		GShapes.SetValue.new(phase_tracker, 2.1, 1.6, &"smooth"),
	])


func _process(_delta: float) -> void:
	if curve == null or extrema == null:
		return
	curve.rebuild_curve()
	extrema.rebuild()
	info_label.text = "phase=%.2f  maxima=%d  minima=%d" % [
		phase_tracker.get_value(),
		extrema.maxima_points().size(),
		extrema.minima_points().size(),
	]


func _eval_dynamic_function(x: float) -> float:
	var p: float = phase_tracker.get_value()
	return sin(x + p) + 0.34 * sin(2.1 * x - 0.6 * p)


func _sample_curve_point(t: float) -> Vector2:
	var x: float = lerpf(axes.x_min, axes.x_max, t)
	return axes.c2p(x, _eval_dynamic_function(x))


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

