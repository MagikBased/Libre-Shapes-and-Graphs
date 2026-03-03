# Demo: GraphInflectionParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var curve: PortParametricFunction2D
var inflections: PortGraphInflectionPoints2D
var phase_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 graph-inflection parity: dynamic inflection-point markers on animated curve")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -3.2
	axes.y_max = 3.2
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	phase_tracker = PortValueTracker.new(0.2)
	add_child(phase_tracker)

	curve = PortParametricFunction2D.new()
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

	inflections = PortGraphInflectionPoints2D.new()
	inflections.axes = axes
	inflections.position = axes.position
	inflections.x_min_value = axes.x_min
	inflections.x_max_value = axes.x_max
	inflections.sample_count = 280
	inflections.function_callable = Callable(self, "_eval_dynamic_function")
	inflections.show_labels = true
	inflections.auto_update = false
	add_child(inflections)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortShowCreation.new(curve, 1.2, &"smooth"))
	play(PortFadeIn.new(inflections, 0.4, &"smooth"))
	play_sequence([
		PortSetValue.new(phase_tracker, 1.4, 1.4, &"smooth"),
		PortSetValue.new(phase_tracker, -0.6, 1.35, &"there_and_back_with_pause"),
		PortSetValue.new(phase_tracker, 2.0, 1.5, &"smooth"),
	])


func _process(_delta: float) -> void:
	if curve == null or inflections == null:
		return
	curve.rebuild_curve()
	inflections.rebuild()
	info_label.text = "phase=%.2f  inflections=%d" % [
		phase_tracker.get_value(),
		inflections.inflection_points().size(),
	]


func _eval_dynamic_function(x: float) -> float:
	var p: float = phase_tracker.get_value()
	return sin(x + p) + 0.28 * sin(2.6 * x - 0.9 * p)


func _sample_curve_point(t: float) -> Vector2:
	var x: float = lerpf(axes.x_min, axes.x_max, t)
	return axes.c2p(x, _eval_dynamic_function(x))


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
