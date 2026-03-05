# Demo: DashedLineParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var start_dot: Circle
var end_dot: Circle
var dashed: LsgDashedLine2D
var phase_tracker: LsgValueTracker


func _ready() -> void:
	_create_caption("Phase 6 dashed-line parity: dashed segment rendering with animated endpoints")

	phase_tracker = GShapes.ValueTracker.new(0.0)
	add_child(phase_tracker)

	start_dot = _make_dot(Vector2(260.0, 420.0), Color(1.0, 0.84, 0.26))
	end_dot = _make_dot(Vector2(980.0, 300.0), Color(0.45, 0.95, 1.0))

	dashed = GShapes.DashedLine2D.new()
	dashed.color = Color(0.86, 0.92, 1.0)
	dashed.stroke_width = 4.0
	dashed.dash_length = 22.0
	dashed.gap_length = 12.0
	add_child(dashed)
	dashed.add_updater(func(target: LsgObject2D, _delta: float) -> void:
		(target as LsgDashedLine2D).set_endpoints(start_dot.position, end_dot.position)
	)

	end_dot.add_updater(func(target: LsgObject2D, _delta: float) -> void:
		var t := phase_tracker.get_value()
		var x := 820.0 + cos(t * 1.2) * 260.0
		var y := 340.0 + sin(t * 2.0) * 130.0
		(target as Node2D).position = Vector2(x, y)
	)

	play(GShapes.ShowCreation.new(dashed, 1.2, &"smooth"))
	wait(0.2)
	play_sequence([
		GShapes.SetValue.new(phase_tracker, TAU * 1.2, 1.6, &"smooth"),
		GShapes.SetValue.new(phase_tracker, TAU * 2.3, 1.7, &"linear"),
		GShapes.SetValue.new(phase_tracker, TAU * 3.1, 1.5, &"smooth"),
	])


func _make_dot(pos: Vector2, c: Color) -> Circle:
	var dot := Circle.new()
	dot.size = Vector2(20.0, 20.0)
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

