# Demo: DecimalNumberParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var phase_tracker: PortValueTracker
var dot: Circle
var theta_value: PortDecimalNumber
var sin_value: PortDecimalNumber
var cos_value: PortDecimalNumber


func _ready() -> void:
	_create_caption("Phase 6 decimal parity: dynamic numeric labels from trackers/callables")

	phase_tracker = PortValueTracker.new(0.0)
	add_child(phase_tracker)

	var center := Vector2(640.0, 360.0)
	var ring := PortPolylineMobject.new()
	ring.position = center
	ring.color = Color(0.8, 0.88, 1.0, 0.45)
	ring.stroke_width = 2.0
	ring.closed = true
	ring.points = _make_circle_points(170.0, 72)
	add_child(ring)

	dot = Circle.new()
	dot.size = Vector2(18.0, 18.0)
	dot.color = Color(1.0, 0.86, 0.2)
	add_child(dot)
	dot.add_updater(func(target: PortObject2D, _delta: float) -> void:
		var theta := phase_tracker.get_value()
		var p := center + Vector2(cos(theta), sin(theta)) * 170.0
		(target as Node2D).position = p
	)

	_create_numeric_panel()

	play_sequence([
		PortSetValue.new(phase_tracker, PI * 1.1, 2.0, &"smooth"),
		PortSetValue.new(phase_tracker, TAU * 1.75, 2.0, &"linear"),
		PortSetValue.new(phase_tracker, -PI * 0.5, 2.0, &"smooth"),
	])


func _create_numeric_panel() -> void:
	_make_key_label("theta:", Vector2(44.0, 84.0))
	theta_value = PortDecimalNumber.new(0.0, 3, true, " rad")
	theta_value.position = Vector2(168.0, 84.0)
	theta_value.color = Color(0.95, 0.98, 1.0)
	theta_value.set_value_source(func(): return phase_tracker.get_value())
	add_child(theta_value)

	_make_key_label("sin(theta):", Vector2(44.0, 124.0))
	sin_value = PortDecimalNumber.new(0.0, 4, true, "")
	sin_value.position = Vector2(168.0, 124.0)
	sin_value.color = Color(0.55, 0.95, 1.0)
	sin_value.set_value_source(func(): return sin(phase_tracker.get_value()))
	add_child(sin_value)

	_make_key_label("cos(theta):", Vector2(44.0, 164.0))
	cos_value = PortDecimalNumber.new(0.0, 4, true, "")
	cos_value.position = Vector2(168.0, 164.0)
	cos_value.color = Color(0.95, 0.78, 0.4)
	cos_value.set_value_source(func(): return cos(phase_tracker.get_value()))
	add_child(cos_value)


func _make_key_label(text: String, pos: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.modulate = Color(0.8, 0.9, 1.0)
	add_child(label)


func _make_circle_points(radius: float, samples: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var count := maxi(16, samples)
	for i in range(count):
		var t := TAU * float(i) / float(count)
		pts.append(Vector2(cos(t), sin(t)) * radius)
	return pts


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
