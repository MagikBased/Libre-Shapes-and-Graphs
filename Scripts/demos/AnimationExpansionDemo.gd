# Demo: AnimationExpansionDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var c_grow: Circle
var c_wiggle: Circle
var c_rotate: Circle
var c_shrink: Circle


func _ready() -> void:
	_create_caption("Phase 6 animation expansion: grow/shrink/rotate/wiggle variants")

	c_grow = _make_circle(Vector2(190.0, 300.0), Color.DEEP_SKY_BLUE)
	c_wiggle = _make_circle(Vector2(430.0, 300.0), Color.GOLD)
	c_rotate = _make_circle(Vector2(670.0, 300.0), Color.MEDIUM_SPRING_GREEN)
	c_shrink = _make_circle(Vector2(910.0, 300.0), Color.ORANGE_RED)

	var ring := _make_ring_marker()
	ring.position = c_rotate.position
	add_child(ring)

	play_group([
		GShapes.GrowFromCenter.new(c_grow, 0.9, &"overshoot"),
		GShapes.Wiggle.new(c_wiggle, 1.2, &"smooth", 3.0),
		GShapes.Rotate.new(c_rotate, TAU * 0.75, 1.1, &"smooth", true),
		GShapes.ShrinkToCenter.new(c_shrink, 0.9, &"smooth"),
	])
	wait(0.2)
	play([
		c_grow.animate.shift(Vector2(0.0, -110.0)).set_run_time(0.7),
		c_wiggle.animate.shift(Vector2(0.0, -110.0)).set_run_time(0.7),
		c_rotate.animate.shift(Vector2(0.0, -110.0)).set_run_time(0.7),
		c_shrink.animate.shift(Vector2(0.0, -110.0)).set_run_time(0.7),
	], 0.75, &"smooth")


func _make_circle(pos: Vector2, c: Color) -> Circle:
	var node := Circle.new()
	node.size = Vector2(76.0, 76.0)
	node.color = c
	node.position = pos
	add_child(node)
	return node


func _make_ring_marker() -> Node2D:
	var r: LsgPolylineMobject = GShapes.PolylineMobject.new()
	r.color = Color(0.8, 0.9, 1.0, 0.45)
	r.stroke_width = 2.0
	r.closed = true
	r.points = _make_circle_points(56.0, 48)
	return r


func _make_circle_points(radius: float, samples: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(samples):
		var t := TAU * float(i) / float(samples)
		pts.append(Vector2(cos(t), sin(t)) * radius)
	return pts


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

