# Demo: TextAndTexDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var text_a: PortTextMobject
var text_b: PortTextMobject
var tex_line: PortTexMobject


func _ready() -> void:
	_create_caption("Text/Tex demo: write + matching-text transform")

	text_a = PortTextMobject.new()
	text_a.text = "A^2 + B^2 = C^2"
	text_a.font_size = 54
	text_a.color = Color.DEEP_SKY_BLUE
	text_a.position = Vector2(220.0, 220.0)
	add_child(text_a)

	text_b = PortTextMobject.new()
	text_b.text = "A^2 = C^2 - B^2"
	text_b.font_size = 54
	text_b.color = Color.ORANGE_RED
	text_b.position = Vector2(220.0, 220.0)
	text_b.modulate.a = 0.0
	add_child(text_b)

	tex_line = PortTexMobject.new()
	tex_line.tex_source = "A = \\sqrt{(C+B)(C-B)}"
	tex_line.font_size = 42
	tex_line.color = Color.GOLD
	tex_line.position = Vector2(220.0, 340.0)
	tex_line.modulate.a = 0.0
	add_child(tex_line)

	play(PortWrite.new(text_a, 1.0, &"linear"))
	wait(0.3)
	play(PortTransformMatchingText.new(
		text_a,
		text_b,
		1.0,
		&"smooth",
		30.0,
		PackedStringArray(["A^2", "B^2", "C^2"]),
		{"+": "-"}
	))
	wait(0.2)
	play(PortFadeIn.new(tex_line, 0.7, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
