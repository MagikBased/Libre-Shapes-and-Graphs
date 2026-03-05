# Demo: ParametricCurveParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var param_curve: GShapesParametricFunction2D
var tracker: GShapesValueTracker
var dot: Circle


func _ready() -> void:
	_create_caption("Phase 6 parametric parity: sampled parametric curve + tracked point")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	param_curve = GShapes.ParametricFunction2D.new()
	param_curve.position = Vector2(640.0, 360.0)
	param_curve.function_name = &"lissajous"
	param_curve.t_min = 0.0
	param_curve.t_max = TAU
	param_curve.sample_count = 260
	param_curve.stroke_width = 3.0
	param_curve.color = Color(0.55, 0.95, 1.0, 0.95)
	param_curve.rebuild_curve()
	param_curve.set_draw_progress(0.0)
	add_child(param_curve)

	dot = Circle.new()
	dot.size = Vector2(18.0, 18.0)
	dot.color = Color(1.0, 0.84, 0.25)
	add_child(dot)
	dot.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		var t: float = tracker.get_value()
		var local_point: Vector2 = param_curve.sample_point(t)
		(target as Node2D).position = param_curve.position + local_point
	)

	play(GShapes.ShowCreation.new(param_curve, 1.4, &"smooth"))
	play(GShapes.FadeIn.new(dot, 0.45, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, TAU * 0.45, 1.3, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 0.92, 1.3, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 1.25, 1.4, &"linear"),
	])


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




