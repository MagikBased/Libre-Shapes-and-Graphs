# Demo: CurvatureCombParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: GShapesValueTracker
var curve: GShapesFourierCurve2D
var comb: GShapesCurvatureComb2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 curvature-comb parity: curve + dynamic curvature spikes")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve = GShapes.FourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 136.0
	curve.sample_count = 420
	curve.stroke_width = 3.0
	curve.color = Color(1.0, 0.72, 0.36, 0.95)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	comb = GShapes.CurvatureComb2D.new()
	comb.position = curve.position
	comb.source_curve = curve
	comb.sample_stride = 6
	comb.comb_scale = 50.0
	comb.max_comb_length = 86.0
	comb.comb_width = 1.4
	comb.comb_color = Color(0.55, 0.95, 1.0, 0.86)
	add_child(comb)
	comb.rebuild()

	play(GShapes.FadeIn.new(curve, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(comb, 0.3, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.5, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.4, &"smooth"),
		GShapes.SetValue.new(tracker, 0.35, 1.1, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null:
		return
	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		comb.rebuild()
		_last_strength = s


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




