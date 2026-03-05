# Demo: CurveIntersectionsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var curve_a: LsgFourierCurve2D
var curve_b: LsgFourierCurve2D
var intersections: LsgCurveIntersections2D
var _last_t: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 curve-intersections parity: dynamic intersection markers across two curves")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve_a = GShapes.FourierCurve2D.new()
	curve_a.position = Vector2(640.0, 360.0)
	curve_a.base_scale = 132.0
	curve_a.sample_count = 380
	curve_a.stroke_width = 2.4
	curve_a.color = Color(1.0, 0.72, 0.36, 0.62)
	curve_a.morph_strength = 0.0
	curve_a.rebuild_curve()
	add_child(curve_a)

	curve_b = GShapes.FourierCurve2D.new()
	curve_b.position = curve_a.position
	curve_b.base_scale = 136.0
	curve_b.sample_count = 380
	curve_b.stroke_width = 2.4
	curve_b.color = Color(0.56, 0.92, 1.0, 0.62)
	curve_b.harmonic_2_phase = 1.35
	curve_b.harmonic_3_phase = -1.1
	curve_b.morph_strength = 1.0
	curve_b.rebuild_curve()
	add_child(curve_b)

	intersections = GShapes.CurveIntersections2D.new()
	intersections.position = curve_a.position
	intersections.source_a = curve_a
	intersections.source_b = curve_b
	intersections.marker_radius = 3.2
	intersections.marker_color = Color(0.86, 1.0, 0.55, 0.98)
	intersections.max_markers = 80
	add_child(intersections)
	intersections.rebuild()

	play(GShapes.FadeIn.new(curve_a, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(curve_b, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(intersections, 0.25, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.5, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.35, &"smooth"),
		GShapes.SetValue.new(tracker, 0.28, 1.1, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve_a == null or curve_b == null or intersections == null:
		return

	var t: float = tracker.get_value()
	if absf(t - _last_t) >= 0.02:
		curve_a.morph_strength = t
		curve_b.morph_strength = 1.0 - t
		curve_b.harmonic_2_phase = 1.35 + 0.9 * t
		curve_b.harmonic_3_phase = -1.1 + 0.6 * t
		curve_a.rebuild_curve()
		curve_b.rebuild_curve()
		intersections.rebuild()
		_last_t = t


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

