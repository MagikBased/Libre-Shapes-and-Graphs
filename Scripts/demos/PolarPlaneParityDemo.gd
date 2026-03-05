# Demo: PolarPlaneParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var plane: LsgPolarPlane2D
var curve: LsgPolarPlot2D
var marker: Circle


func _ready() -> void:
	_create_caption("Phase 6 polar-plane parity: polar grid + polar curve + tracked marker")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	plane = GShapes.PolarPlane2D.new()
	plane.position = Vector2(640.0, 360.0)
	plane.max_radius = 270.0
	plane.radial_step = 54.0
	plane.spoke_count = 18
	add_child(plane)

	curve = GShapes.PolarPlot2D.new()
	curve.position = plane.position
	curve.function_name = &"cardioid"
	curve.theta_min = 0.0
	curve.theta_max = TAU
	curve.sample_count = 320
	curve.radial_scale = 115.0
	curve.stroke_width = 3.0
	curve.color = Color(1.0, 0.66, 0.32, 0.95)
	curve.rebuild_curve()
	curve.set_draw_progress(0.0)
	add_child(curve)

	marker = Circle.new()
	marker.size = Vector2(14.0, 14.0)
	marker.color = Color(0.84, 1.0, 0.4)
	add_child(marker)
	marker.add_updater(func(target: LsgObject2D, _delta: float) -> void:
		var theta: float = tracker.get_value()
		var local_point: Vector2 = curve.sample_point(theta)
		(target as Node2D).position = curve.position + local_point
	)

	play(GShapes.FadeIn.new(plane, 0.55, &"smooth"))
	play(GShapes.ShowCreation.new(curve, 1.2, &"smooth"))
	play(GShapes.FadeIn.new(marker, 0.35, &"smooth"))
	wait(0.15)
	play_sequence([
		GShapes.SetValue.new(tracker, TAU * 0.45, 1.0, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 0.95, 1.15, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 1.3, 1.2, &"linear"),
	])


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

