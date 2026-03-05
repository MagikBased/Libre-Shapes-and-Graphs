# Demo: IndicationDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene
var c: Circle
var t: GShapesTextMobject


func _ready() -> void:
	_create_caption("Indication demo: indicate + flash around")

	c = Circle.new()
	c.size = Vector2(120.0, 120.0)
	c.color = Color.DEEP_SKY_BLUE
	c.position = Vector2(260.0, 300.0)
	add_child(c)

	t = GShapes.TextMobject.new()
	t.text = "Look here"
	t.font_size = 46
	t.color = Color.WHITE
	t.position = Vector2(440.0, 280.0)
	add_child(t)

	play(GShapes.Indicate.new(c, 0.9, &"there_and_back", 1.35, Color.YELLOW))
	wait(0.15)
	play(GShapes.FlashAround.new(t, 0.7, &"there_and_back", Color.GOLD, 3.0, 10.0))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



