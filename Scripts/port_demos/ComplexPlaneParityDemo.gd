# Demo: ComplexPlaneParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var tracker: PortValueTracker
var plane: PortComplexPlane2D
var z_point: Circle
var iz_point: Circle
var z_trace: PortTracedPath2D
var iz_trace: PortTracedPath2D


func _ready() -> void:
	_create_caption("Phase 6 complex-plane parity: z(t) and i*z(t) on a complex grid")

	tracker = PortValueTracker.new(0.0)
	add_child(tracker)

	plane = PortComplexPlane2D.new()
	plane.position = Vector2(640.0, 360.0)
	plane.unit_size = 86.0
	plane.extent_units_x = 6
	plane.extent_units_y = 4
	add_child(plane)

	z_point = Circle.new()
	z_point.size = Vector2(16.0, 16.0)
	z_point.color = Color(1.0, 0.7, 0.32)
	add_child(z_point)
	z_point.add_updater(func(target: PortObject2D, _delta: float) -> void:
		var theta: float = tracker.get_value()
		(target as Node2D).position = _z_world(theta)
	)

	iz_point = Circle.new()
	iz_point.size = Vector2(14.0, 14.0)
	iz_point.color = Color(0.45, 0.95, 1.0)
	add_child(iz_point)
	iz_point.add_updater(func(target: PortObject2D, _delta: float) -> void:
		var theta: float = tracker.get_value()
		(target as Node2D).position = _iz_world(theta)
	)

	z_trace = PortTracedPath2D.new()
	z_trace.set_point_callable(func() -> Variant:
		return z_point.position
	)
	z_trace.local_space = false
	z_trace.color = Color(1.0, 0.7, 0.32, 0.6)
	z_trace.stroke_width = 2.2
	add_child(z_trace)

	iz_trace = PortTracedPath2D.new()
	iz_trace.set_point_callable(func() -> Variant:
		return iz_point.position
	)
	iz_trace.local_space = false
	iz_trace.color = Color(0.45, 0.95, 1.0, 0.6)
	iz_trace.stroke_width = 2.0
	add_child(iz_trace)

	play(PortFadeIn.new(plane, 0.55, &"smooth"))
	play(PortFadeIn.new(z_point, 0.35, &"smooth"))
	play(PortFadeIn.new(iz_point, 0.35, &"smooth"))
	wait(0.15)
	play_sequence([
		PortSetValue.new(tracker, TAU * 0.6, 1.2, &"smooth"),
		PortSetValue.new(tracker, TAU * 1.05, 1.2, &"smooth"),
		PortSetValue.new(tracker, TAU * 1.55, 1.35, &"linear"),
	])


func _z_world(theta: float) -> Vector2:
	var r: float = 2.4
	var real_value: float = r * cos(theta)
	var imag_value: float = r * sin(theta)
	return plane.position + plane.complex_to_point(real_value, imag_value)


func _iz_world(theta: float) -> Vector2:
	var r: float = 2.4
	var real_value: float = -r * sin(theta)
	var imag_value: float = r * cos(theta)
	return plane.position + plane.complex_to_point(real_value, imag_value)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
