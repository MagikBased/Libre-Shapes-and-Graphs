# Demo: CurveWindowParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var curve: LsgFourierCurve2D
var window_curve: LsgCurveWindow2D
var tip: Circle

var _last_strength: float = -9999.0
var window_size: float = 0.24


func _ready() -> void:
	_create_caption("Phase 6 curve-window parity: sliding sub-curve over evolving source path")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	curve = GShapes.FourierCurve2D.new()
	curve.position = Vector2(640.0, 360.0)
	curve.base_scale = 136.0
	curve.sample_count = 420
	curve.stroke_width = 2.3
	curve.color = Color(0.76, 0.84, 0.96, 0.42)
	curve.morph_strength = tracker.get_value()
	curve.rebuild_curve()
	add_child(curve)
	_last_strength = curve.morph_strength

	window_curve = GShapes.CurveWindow2D.new()
	window_curve.position = curve.position
	window_curve.source_curve = curve
	window_curve.alpha_start = 0.0
	window_curve.alpha_end = window_size
	window_curve.window_samples = 84
	window_curve.stroke_width = 4.0
	window_curve.color = Color(1.0, 0.74, 0.36, 0.95)
	window_curve.rebuild_window()
	add_child(window_curve)

	tip = Circle.new()
	tip.size = Vector2(12.0, 12.0)
	tip.color = Color(0.82, 1.0, 0.52, 0.95)
	add_child(tip)

	play(GShapes.FadeIn.new(curve, 0.45, &"smooth"))
	play(GShapes.FadeIn.new(window_curve, 0.3, &"smooth"))
	play(GShapes.FadeIn.new(tip, 0.25, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(tracker, 0.42, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 1.0, 1.45, &"smooth"),
		GShapes.SetValue.new(tracker, 0.28, 1.15, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or curve == null or window_curve == null:
		return

	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		curve.morph_strength = s
		curve.rebuild_curve()
		_last_strength = s

	var start_alpha: float = clampf(fposmod(s * 1.35, 1.0), 0.0, 1.0)
	var end_alpha: float = clampf(start_alpha + window_size, 0.0, 1.0)
	window_curve.alpha_start = start_alpha
	window_curve.alpha_end = end_alpha
	window_curve.rebuild_window()

	if window_curve.points.size() > 0:
		tip.position = window_curve.position + window_curve.points[window_curve.points.size() - 1]


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

