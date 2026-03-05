# Demo: SecantIterationParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var curve: LsgParametricFunction2D
var secant_iter: LsgSecantIteration2D
var k_tracker: LsgValueTracker
var x0_tracker: LsgValueTracker
var x1_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 secant-iteration parity: two-seed root approximation on dynamic function")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -2.8
	axes.y_max = 2.8
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	k_tracker = GShapes.ValueTracker.new(0.35)
	x0_tracker = GShapes.ValueTracker.new(-2.0)
	x1_tracker = GShapes.ValueTracker.new(2.8)
	add_child(k_tracker)
	add_child(x0_tracker)
	add_child(x1_tracker)

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

	secant_iter = GShapes.SecantIteration2D.new()
	secant_iter.axes = axes
	secant_iter.position = axes.position
	secant_iter.function_callable = Callable(self, "_eval_dynamic_function")
	secant_iter.x0 = x0_tracker.get_value()
	secant_iter.x1 = x1_tracker.get_value()
	secant_iter.iteration_count = 6
	secant_iter.auto_update = false
	add_child(secant_iter)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(curve, 1.2, &"smooth"))
	play(GShapes.FadeIn.new(secant_iter, 0.35, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x0_tracker, -3.0, 1.2, &"smooth"),
		GShapes.SetValue.new(x1_tracker, 2.0, 1.2, &"smooth"),
		GShapes.SetValue.new(k_tracker, -0.25, 1.35, &"there_and_back_with_pause"),
		GShapes.SetValue.new(x1_tracker, 1.2, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if curve == null or secant_iter == null:
		return
	curve.rebuild_curve()
	secant_iter.x0 = x0_tracker.get_value()
	secant_iter.x1 = x1_tracker.get_value()
	secant_iter.rebuild()
	info_label.text = "k=%.2f  x0=%.2f  x1=%.2f  secant_est=%.4f" % [
		k_tracker.get_value(),
		secant_iter.x0,
		secant_iter.x1,
		secant_iter.current_estimate(),
	]


func _eval_dynamic_function(x: float) -> float:
	return sin(x) - k_tracker.get_value()


func _sample_curve_point(t: float) -> Vector2:
	var x: float = lerpf(axes.x_min, axes.x_max, t)
	return axes.c2p(x, _eval_dynamic_function(x))


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

