# Demo: FalsePositionIterationParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var curve: PortParametricFunction2D
var false_pos: PortFalsePositionIteration2D
var k_tracker: PortValueTracker
var left_tracker: PortValueTracker
var right_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 false-position parity: chord-based root approximation on dynamic function")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -2.8
	axes.y_max = 2.8
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	k_tracker = PortValueTracker.new(0.35)
	left_tracker = PortValueTracker.new(-3.2)
	right_tracker = PortValueTracker.new(2.6)
	add_child(k_tracker)
	add_child(left_tracker)
	add_child(right_tracker)

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

	false_pos = PortFalsePositionIteration2D.new()
	false_pos.axes = axes
	false_pos.position = axes.position
	false_pos.function_callable = Callable(self, "_eval_dynamic_function")
	false_pos.left_x = left_tracker.get_value()
	false_pos.right_x = right_tracker.get_value()
	false_pos.iteration_count = 6
	false_pos.auto_update = false
	add_child(false_pos)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortShowCreation.new(curve, 1.2, &"smooth"))
	play(PortFadeIn.new(false_pos, 0.35, &"smooth"))
	play_sequence([
		PortSetValue.new(left_tracker, -2.5, 1.2, &"smooth"),
		PortSetValue.new(right_tracker, 1.9, 1.2, &"smooth"),
		PortSetValue.new(k_tracker, -0.22, 1.35, &"there_and_back_with_pause"),
		PortSetValue.new(left_tracker, -3.1, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if curve == null or false_pos == null:
		return
	curve.rebuild_curve()
	false_pos.left_x = left_tracker.get_value()
	false_pos.right_x = right_tracker.get_value()
	false_pos.rebuild()
	info_label.text = "k=%.2f  [a,b]=[%.2f, %.2f]  false_pos_est=%.4f" % [
		k_tracker.get_value(),
		false_pos.left_x,
		false_pos.right_x,
		false_pos.current_estimate(),
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
