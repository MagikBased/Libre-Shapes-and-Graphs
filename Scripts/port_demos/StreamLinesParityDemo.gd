# Demo: StreamLinesParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var tracker: PortValueTracker
var lines: PortStreamLines2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 stream-line parity: sampled stream lines + animated field strength")

	tracker = PortValueTracker.new(0.35)
	add_child(tracker)

	lines = PortStreamLines2D.new()
	lines.position = Vector2(640.0, 360.0)
	lines.field_name = &"swirl"
	lines.strength = tracker.get_value()
	lines.seed_step = 76.0
	lines.steps_per_line = 36
	lines.step_size = 0.09
	lines.line_width = 1.7
	lines.color = Color(0.6, 0.9, 1.0, 0.75)
	add_child(lines)
	lines.rebuild()
	_last_strength = lines.strength

	play_sequence([
		PortSetValue.new(tracker, 0.95, 1.8, &"smooth"),
		PortSetValue.new(tracker, 0.25, 1.4, &"smooth"),
		PortSetValue.new(tracker, 1.2, 1.2, &"linear"),
	])


func _process(_delta: float) -> void:
	if lines == null or tracker == null:
		return
	var strength_value: float = tracker.get_value()
	if absf(strength_value - _last_strength) >= 0.04:
		lines.strength = strength_value
		lines.rebuild()
		_last_strength = strength_value


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
