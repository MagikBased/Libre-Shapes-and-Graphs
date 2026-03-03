# Demo: CompositionDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var circle_a: Circle
var circle_b: Circle


func _ready() -> void:
	_create_caption("Composition demo: animation group and sequence")

	circle_a = _make_circle(Vector2(160.0, 240.0), Color.ORANGE_RED)
	circle_b = _make_circle(Vector2(160.0, 440.0), Color.DEEP_SKY_BLUE)

	play_group([
		PortMoveTo.new(circle_a, Vector2(520.0, 240.0), 1.1, &"smooth"),
		PortFadeToColor.new(circle_a, Color.ORANGE_RED, Color.GOLD, 1.1, &"smooth"),
	])
	wait_seconds(0.3)
	play_sequence([
		PortMoveTo.new(circle_b, Vector2(520.0, 440.0), 0.9, &"smooth"),
		PortTransform.new(circle_b, null, Vector2(1.6, 1.6), deg_to_rad(120.0), 0.9, &"smooth"),
		PortMoveTo.new(circle_b, Vector2(980.0, 440.0), 0.9, &"smooth"),
	])


func _make_circle(pos: Vector2, circle_color: Color) -> Circle:
	var c := Circle.new()
	c.size = Vector2(70.0, 70.0)
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
