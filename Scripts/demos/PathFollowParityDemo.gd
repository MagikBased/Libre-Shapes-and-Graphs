# Demo: PathFollowParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene


func _ready() -> void:
	_create_caption("Phase 6 path-follow parity: move-along-path with tangent orientation")

	var center := Vector2(640.0, 360.0)
	var path: LsgPolylineMobject = GShapes.PolylineMobject.new()
	path.position = center
	path.color = Color(0.72, 0.86, 1.0, 0.8)
	path.stroke_width = 3.0
	path.closed = true
	path.points = _make_lemniscate_points(300.0, 90)
	add_child(path)

	var mover: LsgPolylineMobject = GShapes.PolylineMobject.new()
	mover.color = Color(1.0, 0.86, 0.2, 0.95)
	mover.closed = true
	mover.points = PackedVector2Array([
		Vector2(24.0, 0.0),
		Vector2(-14.0, -10.0),
		Vector2(-9.0, 0.0),
		Vector2(-14.0, 10.0),
	])
	add_child(mover)

	var tracer: LsgTracedPath2D = GShapes.TracedPath2D.new()
	tracer.color = Color(0.26, 1.0, 0.78, 0.9)
	tracer.stroke_width = 2.0
	tracer.min_distance = 1.0
	tracer.max_points = 1200
	tracer.local_space = true
	tracer.set_target(mover)
	add_child(tracer)

	var sweep: LsgMoveAlongPath2D = GShapes.MoveAlongPath2D.new(
		mover,
		path.points,
		8.0,
		&"linear",
		true,
		true,
		path
	)
	sweep.orientation_angle_offset = 0.0
	play(sweep)

	wait(0.25)
	play(GShapes.FadeToColor.new(path, path.color, Color(0.95, 0.76, 0.28, 0.95), 0.7, &"smooth"))


func _make_lemniscate_points(scale_x: float, samples: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var count := maxi(16, samples)
	for i in range(count):
		var t := TAU * float(i) / float(count)
		var denom := 1.0 + pow(sin(t), 2.0)
		var x := (scale_x * cos(t)) / denom
		var y := (scale_x * 0.55 * sin(t) * cos(t)) / denom
		pts.append(Vector2(x, y))
	return pts


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

