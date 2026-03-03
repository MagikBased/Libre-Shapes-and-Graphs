# Demo: FadeTransformDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var source_circle: Circle
var destination_rect: Rectangle


func _ready() -> void:
	_create_caption("FadeTransform demo: source fades out while destination fades/scales in")

	source_circle = Circle.new()
	source_circle.size = Vector2(120.0, 120.0)
	source_circle.color = Color.ORANGE_RED
	source_circle.position = Vector2(340.0, 340.0)
	add_child(source_circle)

	destination_rect = Rectangle.new()
	destination_rect.size = Vector2(150.0, 100.0)
	destination_rect.color = Color.DEEP_SKY_BLUE
	destination_rect.position = Vector2(880.0, 340.0)
	destination_rect.modulate.a = 0.0
	add_child(destination_rect)

	play(PortFadeTransform.new(source_circle, destination_rect, 1.2, &"smooth", true))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
