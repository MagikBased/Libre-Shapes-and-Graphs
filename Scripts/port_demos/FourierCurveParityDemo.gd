# Demo: FourierCurveParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var tracker: PortValueTracker
var curve: PortFourierCurve2D
var marker: Circle
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 Fourier-curve parity: harmonic curve with animated morph strength")

	tracker = PortValueTracker.new(0.0)
	add_child(tracker)

	curve = PortFourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 132.0
	curve.sample_count = 420
	curve.stroke_width = 3.0
	curve.color = Color(1.0, 0.76, 0.38, 0.95)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	marker = Circle.new()
	marker.size = Vector2(12.0, 12.0)
	marker.color = Color(0.82, 1.0, 0.5)
	add_child(marker)
	marker.add_updater(func(target: PortObject2D, _delta: float) -> void:
		if curve.points.is_empty():
			return
		var angle: float = tracker.get_value() * TAU
		var samples: int = maxi(3, curve.sample_count)
		var index: int = int(floorf((angle / TAU) * float(samples - 1)))
		index = clampi(index, 0, curve.points.size() - 1)
		(target as Node2D).position = curve.position + curve.points[index]
	)

	play(PortFadeIn.new(curve, 0.45, &"smooth"))
	play(PortFadeIn.new(marker, 0.25, &"smooth"))
	wait(0.2)
	play_sequence([
		PortSetValue.new(tracker, 0.45, 1.1, &"smooth"),
		PortSetValue.new(tracker, 1.0, 1.5, &"smooth"),
		PortSetValue.new(tracker, 0.3, 1.0, &"linear"),
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
