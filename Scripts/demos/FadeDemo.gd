# Demo: FadeDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var circle_a: Circle
var circle_b: Circle


func _ready() -> void:
	_create_caption("Fade demo: fade in, pause, then fade out")

	circle_a = _make_circle(Vector2(360.0, 320.0), Color.ORANGE_RED)
	circle_b = _make_circle(Vector2(760.0, 320.0), Color.DEEP_SKY_BLUE)

	play([
		GShapes.FadeIn.new(circle_a, 1.0, &"smooth"),
		GShapes.FadeIn.new(circle_b, 1.0, &"smooth"),
	])
	wait_seconds(0.7)
	play([
		GShapes.FadeOut.new(circle_a, 1.0, &"smooth"),
		GShapes.FadeOut.new(circle_b, 1.0, &"smooth"),
	])


func _make_circle(pos: Vector2, circle_color: Color) -> Circle:
	var c := Circle.new()
	c.size = Vector2(120.0, 120.0)
	c.color = circle_color
	c.position = pos
	add_child(c)
	return c


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



