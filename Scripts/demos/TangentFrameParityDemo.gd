# Demo: TangentFrameParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: GShapesValueTracker
var curve: GShapesFourierCurve2D
var frame: GShapesTangentFrame2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 tangent-frame parity: moving tangent/normal frame on evolving curve")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve = GShapes.FourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 136.0
	curve.sample_count = 420
	curve.stroke_width = 3.0
	curve.color = Color(1.0, 0.74, 0.36, 0.95)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	frame = GShapes.TangentFrame2D.new()
	frame.position = curve.position
	frame.source_curve = curve
	frame.alpha = 0.0
	frame.frame_scale = 78.0
	add_child(frame)
	frame.rebuild()

	play(GShapes.FadeIn.new(curve, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(frame, 0.3, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.45, 1.15, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.35, &"smooth"),
		GShapes.SetValue.new(tracker, 0.3, 1.1, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null or frame == null:
		return
	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		_last_strength = s
	frame.alpha = fposmod(s * 1.7, 1.0)
	frame.rebuild()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




