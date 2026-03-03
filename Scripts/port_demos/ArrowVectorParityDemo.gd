# Demo: ArrowVectorParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var phase_tracker: PortValueTracker
var origin_dot: Circle
var tip_dot: Circle
var vector_arrow: PortArrow2D
var magnitude_readout: PortDecimalNumber


func _ready() -> void:
	_create_caption("Phase 6 arrow parity: dynamic vector arrow with magnitude readout")

	phase_tracker = PortValueTracker.new(0.0)
	add_child(phase_tracker)

	origin_dot = _make_dot(Vector2(640.0, 360.0), Color(0.95, 0.96, 1.0))
	tip_dot = _make_dot(Vector2(840.0, 360.0), Color(1.0, 0.84, 0.25))

	vector_arrow = PortArrow2D.new()
	vector_arrow.color = Color(0.46, 0.95, 1.0)
	vector_arrow.stroke_width = 4.0
	vector_arrow.tip_length = 22.0
	vector_arrow.tip_angle_deg = 30.0
	add_child(vector_arrow)
	vector_arrow.add_updater(func(target: PortObject2D, _delta: float) -> void:
		(target as PortArrow2D).set_points(origin_dot.position, tip_dot.position)
	)

	tip_dot.add_updater(func(target: PortObject2D, _delta: float) -> void:
		var t: float = phase_tracker.get_value()
		var x: float = 640.0 + cos(t * 1.1) * 280.0
		var y: float = 360.0 + sin(t * 1.8) * 170.0
		(target as Node2D).position = Vector2(x, y)
	)

	magnitude_readout = PortDecimalNumber.new(0.0, 2, false, "")
	magnitude_readout.position = Vector2(560.0, 170.0)
	magnitude_readout.font_size = 38
	magnitude_readout.color = Color(0.63, 1.0, 0.9)
	magnitude_readout.set_value_source(func():
		return origin_dot.position.distance_to(tip_dot.position)
	)
	add_child(magnitude_readout)

	play(PortShowCreation.new(vector_arrow, 1.1, &"smooth"))
	wait(0.2)
	play_sequence([
		PortSetValue.new(phase_tracker, TAU * 1.0, 1.6, &"smooth"),
		PortSetValue.new(phase_tracker, TAU * 2.2, 1.8, &"linear"),
		PortSetValue.new(phase_tracker, TAU * 3.1, 1.7, &"smooth"),
	])


func _make_dot(pos: Vector2, c: Color) -> Circle:
	var dot := Circle.new()
	dot.size = Vector2(18.0, 18.0)
	dot.color = c
	dot.position = pos
	add_child(dot)
	return dot


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
