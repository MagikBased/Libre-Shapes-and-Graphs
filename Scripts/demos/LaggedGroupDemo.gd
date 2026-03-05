# Demo: LaggedGroupDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var circles: Array[Circle] = []


func _ready() -> void:
	_create_caption("Lagged group demo: staggered starts with overlap")

	var y := 160.0
	for i in range(6):
		var c := Circle.new()
		c.size = Vector2(52.0, 52.0)
		c.color = Color.from_hsv(float(i) / 6.0, 0.8, 1.0)
		c.position = Vector2(140.0, y)
		add_child(c)
		circles.append(c)
		y += 78.0

	var animations: Array[LsgAnimation] = []
	for c in circles:
		animations.append(GShapes.MoveTo.new(c, Vector2(1020.0, c.position.y), 1.2, &"smooth"))

	play_lagged(animations, 0.28)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
