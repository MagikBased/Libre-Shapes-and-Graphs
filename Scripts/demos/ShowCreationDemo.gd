# Demo: ShowCreationDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var line_a: Line
var line_b: Line


func _ready() -> void:
	_create_caption("ShowCreation demo: progressive line reveal")

	line_a = _make_line(Vector2(120.0, 240.0), Vector2(1000.0, 240.0), Color.ORANGE_RED)
	line_b = _make_line(Vector2(120.0, 420.0), Vector2(1000.0, 420.0), Color.DEEP_SKY_BLUE)

	play(GShapes.ShowCreation.new(line_a, 1.8, &"smooth"))
	wait_seconds(0.5)
	play(GShapes.ShowCreation.new(line_b, 1.8, &"smooth"))


func _make_line(start_point: Vector2, end_point: Vector2, line_color: Color) -> Line:
	var line := Line.new()
	line.start_point = start_point
	line.end_point = end_point
	line.color = line_color
	add_child(line)
	line.set_draw_progress(0.0)
	return line


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
