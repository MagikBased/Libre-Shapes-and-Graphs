# Demo: MathTexParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var eq_a: PortMathTexMobject
var eq_b: PortMathTexMobject
var eq_c: PortMathTexMobject
var eq_d: PortMathTexMobject
var eq_e: PortMathTexMobject


func _ready() -> void:
	_create_caption("Phase 6 text/tex parity demo: expression tokens + multiline + alignment")

	eq_a = PortMathTexMobject.new()
	eq_a.set_expressions(["f(x)", "\\frac{1}{2}x^2 + 3x + 1"])
	eq_a.separator = " = "
	eq_a.align_mode = &"left"
	eq_a.font_size = 44
	eq_a.color = Color.DEEP_SKY_BLUE
	eq_a.position = Vector2(140.0, 180.0)
	add_child(eq_a)

	eq_b = PortMathTexMobject.new()
	eq_b.set_expressions(["f'(x)", "x + 3"])
	eq_b.separator = " = "
	eq_b.align_mode = &"left"
	eq_b.font_size = 44
	eq_b.color = Color.ORANGE_RED
	eq_b.position = eq_a.position
	eq_b.modulate.a = 0.0
	add_child(eq_b)

	eq_c = PortMathTexMobject.new()
	eq_c.set_expressions([
		"\\sum_{i=0}^{n} i = \\frac{n(n+1)}{2}",
		"\\text{limit } x \\to \\infty"
	])
	eq_c.multiline = true
	eq_c.align_mode = &"center"
	eq_c.font_size = 36
	eq_c.color = Color.GOLD
	eq_c.position = Vector2(140.0, 330.0)
	eq_c.modulate.a = 0.0
	eq_c.isolate_tokens = PackedStringArray(["f(x)", "f'(x)", "x", "n"])
	add_child(eq_c)

	eq_d = PortMathTexMobject.new()
	eq_d.set_expressions(["\\sum_{i=1}^{n} i", "\\frac{n(n+1)}{2}"])
	eq_d.separator = " = "
	eq_d.align_mode = &"left"
	eq_d.font_size = 36
	eq_d.color = Color.MEDIUM_SPRING_GREEN
	eq_d.position = Vector2(140.0, 510.0)
	eq_d.token_groups = [
		PackedStringArray(["sum", "i", "n"]),
		PackedStringArray(["n(n+1)", "2"])
	]
	add_child(eq_d)

	eq_e = PortMathTexMobject.new()
	eq_e.set_expressions(["2\\sum_{i=1}^{n} i", "n(n+1)"])
	eq_e.separator = " = "
	eq_e.align_mode = &"left"
	eq_e.font_size = 36
	eq_e.color = Color.SPRING_GREEN
	eq_e.position = eq_d.position
	eq_e.modulate.a = 0.0
	eq_e.token_groups = [
		PackedStringArray(["sum", "i", "n"]),
		PackedStringArray(["n(n+1)", "2"])
	]
	add_child(eq_e)

	play(PortWrite.new(eq_a, 1.1, &"linear"))
	wait(0.25)
	play(PortTransformMatchingText.new(
		eq_a,
		eq_b,
		1.0,
		&"smooth",
		24.0
	))
	wait(0.25)
	play(PortFadeIn.new(eq_c, 0.8, &"smooth"))
	wait(0.2)
	play(PortWrite.new(eq_d, 0.9, &"linear"))
	wait(0.2)
	play(PortTransformMatchingText.new(
		eq_d,
		eq_e,
		1.0,
		&"smooth",
		16.0
	))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
