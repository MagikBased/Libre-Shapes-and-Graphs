# Demo: DynamicHelpersDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: GShapesValueTracker
var moving_dot: Circle
var traced_path: GShapesTracedPath2D


func _ready() -> void:
	_create_caption("Phase 6 dynamic helpers: always-redraw + traced path")

	var center := Vector2(640.0, 360.0)
	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	var frame := _make_orbit_frame(center)
	add_child(frame)

	moving_dot = Circle.new()
	moving_dot.size = Vector2(20.0, 20.0)
	moving_dot.color = Color(1.0, 0.84, 0.2)
	moving_dot.position = center
	add_child(moving_dot)

	traced_path = GShapes.TracedPath2D.new()
	traced_path.color = Color(0.2, 0.9, 1.0, 0.9)
	traced_path.stroke_width = 3.0
	traced_path.min_distance = 1.5
	traced_path.local_space = true
	traced_path.position = Vector2.ZERO
	traced_path.set_target(moving_dot)
	add_child(traced_path)

	var dynamic_line: GShapesAlwaysRedraw2D = GShapes.AlwaysRedraw2D.new(func():
		var line := Line.new()
		line.color = Color(0.85, 0.9, 1.0, 0.45)
		line.stroke_width = 2.0
		line.set_endpoints(center, moving_dot.position)
		return line
	)
	add_child(dynamic_line)

	moving_dot.add_updater(func(node: GShapesObject2D, _delta: float) -> void:
		var t := tracker.get_value()
		var radius_x := 260.0
		var radius_y := 180.0
		var x := center.x + cos(t * 1.2) * radius_x
		var y := center.y + sin(t * 2.1) * radius_y
		(node as Node2D).position = Vector2(x, y)
	)

	play_sequence([
		GShapes.SetValue.new(tracker, TAU * 2.0, 3.0, &"linear"),
		GShapes.SetValue.new(tracker, TAU * 4.5, 3.0, &"linear"),
		GShapes.SetValue.new(tracker, TAU * 6.8, 3.2, &"linear"),
	])


func _make_orbit_frame(center: Vector2) -> GShapesPolylineMobject:
	var frame: GShapesPolylineMobject = GShapes.PolylineMobject.new()
	frame.color = Color(0.8, 0.85, 0.95, 0.35)
	frame.stroke_width = 2.0
	frame.closed = true
	frame.points = PackedVector2Array([
		center + Vector2(-260.0, -180.0),
		center + Vector2(260.0, -180.0),
		center + Vector2(260.0, 180.0),
		center + Vector2(-260.0, 180.0),
	])
	return frame


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




