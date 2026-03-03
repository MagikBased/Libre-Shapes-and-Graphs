# Demo: NormalOffsetParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var tracker: PortValueTracker
var curve: PortFourierCurve2D
var offset_curve: PortNormalOffsetCurve2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 normal-offset parity: animated offset curve from local normals")

	tracker = PortValueTracker.new(0.0)
	add_child(tracker)

	curve = PortFourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 134.0
	curve.sample_count = 420
	curve.stroke_width = 2.4
	curve.color = Color(0.78, 0.86, 0.98, 0.45)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	offset_curve = PortNormalOffsetCurve2D.new()
	offset_curve.position = curve.position
	offset_curve.source_curve = curve
	offset_curve.offset_distance = 26.0
	offset_curve.sample_count = 220
	offset_curve.stroke_width = 3.8
	offset_curve.color = Color(1.0, 0.72, 0.34, 0.95)
	offset_curve.rebuild_offset()
	add_child(offset_curve)

	play(PortFadeIn.new(curve, 0.45, &"smooth"))
	play(PortFadeIn.new(offset_curve, 0.3, &"smooth"))
	wait(0.2)
	play_sequence([
		PortSetValue.new(tracker, 0.48, 1.2, &"smooth"),
		PortSetValue.new(tracker, 1.0, 1.4, &"smooth"),
		PortSetValue.new(tracker, 0.32, 1.1, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null or offset_curve == null:
		return

	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		_last_strength = s

	offset_curve.offset_distance = 18.0 + 18.0 * s
	offset_curve.rebuild_offset()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
