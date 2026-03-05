# Demo: NearestPointParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var curve: LsgFourierCurve2D
var probe: Circle
var nearest: LsgNearestPointOnCurve2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 nearest-point parity: probe-to-curve nearest projection helper")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve = GShapes.FourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 132.0
	curve.sample_count = 420
	curve.stroke_width = 2.8
	curve.color = Color(1.0, 0.72, 0.36, 0.72)
	curve.morph_strength = 0.0
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	probe = Circle.new()
	probe.size = Vector2(13.0, 13.0)
	probe.color = Color(0.8, 0.96, 1.0, 0.95)
	add_child(probe)
	probe.add_updater(func(target: LsgObject2D, _delta: float) -> void:
		var t: float = tracker.get_value()
		var x: float = 640.0 + 300.0 * cos(t * TAU * 0.7 + 0.2)
		var y: float = 360.0 + 170.0 * sin(t * TAU * 1.3)
		(target as Node2D).position = Vector2(x, y)
	)

	nearest = GShapes.NearestPointOnCurve2D.new()
	nearest.position = curve.position
	nearest.source_curve = curve
	nearest.probe_node = probe
	nearest.sample_count = 300
	add_child(nearest)
	nearest.rebuild()

	play(GShapes.FadeIn.new(curve, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(probe, 0.25, &"smooth"))
	play(GShapes.FadeIn.new(nearest, 0.25, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.45, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.45, &"smooth"),
		GShapes.SetValue.new(tracker, 0.22, 1.15, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null:
		return
	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		_last_strength = s


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

