# Demo: AnimationQueueDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene
var circle_a: Circle
var circle_b: Circle


func _ready() -> void:
	circle_a = _make_circle(Vector2(140.0, 220.0), Color.WHITE)
	circle_b = _make_circle(Vector2(140.0, 420.0), Color.WHITE)

	_create_caption("Queue demo: group 1, wait, then group 2")

	play([
		GShapes.MoveTo.new(circle_a, Vector2(980.0, 220.0), 1.5, &"smooth"),
		GShapes.FadeToColor.new(circle_a, Color.WHITE, Color.ORANGE_RED, 1.5, &"smooth"),
	])
	wait_seconds(0.6)
	play([
		GShapes.MoveTo.new(circle_b, Vector2(980.0, 420.0), 1.5, &"smooth"),
		GShapes.FadeToColor.new(circle_b, Color.WHITE, Color.DEEP_SKY_BLUE, 1.5, &"smooth"),
	])


func _make_circle(pos: Vector2, color: Color) -> Circle:
	var c := Circle.new()
	c.size = Vector2(56.0, 56.0)
	c.color = color
	c.position = pos
	add_child(c)
	return c


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



