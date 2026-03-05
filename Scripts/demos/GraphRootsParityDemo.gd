# Demo: GraphRootsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var dynamic_curve: GShapesParametricFunction2D
var roots_helper: GShapesGraphRoots2D
var k_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 graph-roots parity: dynamic x-intercept detection on animated function")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -2.8
	axes.y_max = 2.8
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	k_tracker = GShapes.ValueTracker.new(0.7)
	add_child(k_tracker)

	dynamic_curve = GShapes.ParametricFunction2D.new()
	dynamic_curve.position = axes.position
	dynamic_curve.t_min = 0.0
	dynamic_curve.t_max = 1.0
	dynamic_curve.sample_count = 300
	dynamic_curve.color = Color(0.34, 0.84, 1.0, 0.9)
	dynamic_curve.stroke_width = 2.8
	dynamic_curve.parametric_source = Callable(self, "_sample_curve_point")
	dynamic_curve.rebuild_curve()
	dynamic_curve.set_draw_progress(0.0)
	add_child(dynamic_curve)

	roots_helper = GShapes.GraphRoots2D.new()
	roots_helper.axes = axes
	roots_helper.position = axes.position
	roots_helper.x_min_value = axes.x_min
	roots_helper.x_max_value = axes.x_max
	roots_helper.sample_count = 260
	roots_helper.function_callable = Callable(self, "_eval_dynamic_function")
	roots_helper.show_labels = true
	roots_helper.auto_update = false
	add_child(roots_helper)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(dynamic_curve, 1.15, &"smooth"))
	play(GShapes.FadeIn.new(roots_helper, 0.35, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(k_tracker, -0.35, 1.45, &"smooth"),
		GShapes.SetValue.new(k_tracker, 0.15, 1.1, &"there_and_back_with_pause"),
		GShapes.SetValue.new(k_tracker, -0.75, 1.35, &"smooth"),
	])


func _process(_delta: float) -> void:
	if dynamic_curve == null or roots_helper == null or k_tracker == null:
		return
	dynamic_curve.rebuild_curve()
	roots_helper.rebuild()
	var rts: Array[float] = roots_helper.roots()
	info_label.text = "k=%.2f  roots=%d" % [k_tracker.get_value(), rts.size()]


func _eval_dynamic_function(x: float) -> float:
	return sin(x) - k_tracker.get_value()


func _sample_curve_point(t: float) -> Vector2:
	var x: float = lerpf(axes.x_min, axes.x_max, t)
	var y: float = _eval_dynamic_function(x)
	return axes.c2p(x, y)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




