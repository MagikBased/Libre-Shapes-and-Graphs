# Demo: OsculatingCircleParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var curve: LsgFourierCurve2D
var osc_circle: LsgOsculatingCircle2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 osculating-circle parity: local curvature circle on evolving curve")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve = GShapes.FourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 134.0
	curve.sample_count = 420
	curve.stroke_width = 2.6
	curve.color = Color(0.78, 0.86, 0.98, 0.45)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	osc_circle = GShapes.OsculatingCircle2D.new()
	osc_circle.position = curve.position
	osc_circle.source_curve = curve
	osc_circle.alpha = 0.0
	osc_circle.min_radius = 10.0
	osc_circle.max_radius = 520.0
	add_child(osc_circle)
	osc_circle.rebuild()

	play(GShapes.FadeIn.new(curve, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(osc_circle, 0.3, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.44, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.4, &"smooth"),
		GShapes.SetValue.new(tracker, 0.26, 1.15, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null or osc_circle == null:
		return

	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		_last_strength = s

	osc_circle.alpha = fposmod(s * 1.85, 1.0)
	osc_circle.rebuild()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

