# Demo: PolarPlotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var polar_curve: LsgPolarPlot2D
var marker: Circle


func _ready() -> void:
	_create_caption("Phase 6 polar parity: sampled polar plot + tracked angle marker")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	polar_curve = GShapes.PolarPlot2D.new()
	polar_curve.position = Vector2(640.0, 360.0)
	polar_curve.function_name = &"rose"
	polar_curve.theta_min = 0.0
	polar_curve.theta_max = TAU
	polar_curve.sample_count = 320
	polar_curve.radial_scale = 180.0
	polar_curve.stroke_width = 3.0
	polar_curve.color = Color(1.0, 0.62, 0.3, 0.95)
	polar_curve.rebuild_curve()
	polar_curve.set_draw_progress(0.0)
	add_child(polar_curve)

	marker = Circle.new()
	marker.size = Vector2(16.0, 16.0)
	marker.color = Color(0.86, 1.0, 0.4)
	add_child(marker)
	marker.add_updater(func(target: LsgObject2D, _delta: float) -> void:
		var theta: float = tracker.get_value()
		var local_point: Vector2 = polar_curve.sample_point(theta)
		(target as Node2D).position = polar_curve.position + local_point
	)

	play(GShapes.ShowCreation.new(polar_curve, 1.2, &"smooth"))
	play(GShapes.FadeIn.new(marker, 0.4, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, TAU * 0.4, 1.1, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 0.85, 1.1, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 1.2, 1.2, &"linear"),
	])


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

