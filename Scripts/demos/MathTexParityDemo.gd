# Demo: MathTexParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var eq_a: GShapesMathTexMobject
var eq_b: GShapesMathTexMobject
var eq_c: GShapesMathTexMobject
var eq_d: GShapesMathTexMobject
var eq_e: GShapesMathTexMobject
var eq_f: GShapesMathTexMobject
var eq_g: GShapesMathTexMobject


func _ready() -> void:
	_create_caption("Phase 7 TeX parity demo: command coverage + matching + fallback diagnostics")

	eq_a = GShapes.MathTexMobject.new()
	eq_a.set_expressions(["f(x)", "\\frac{1}{2}x^2 + 3x + 1"])
	eq_a.separator = " = "
	eq_a.align_mode = &"left"
	eq_a.font_size = 44
	eq_a.color = Color.DEEP_SKY_BLUE
	eq_a.position = Vector2(140.0, 180.0)
	add_child(eq_a)

	eq_b = GShapes.MathTexMobject.new()
	eq_b.set_expressions(["f'(x)", "x + 3"])
	eq_b.separator = " = "
	eq_b.align_mode = &"left"
	eq_b.font_size = 44
	eq_b.color = Color.ORANGE_RED
	eq_b.position = eq_a.position
	eq_b.modulate.a = 0.0
	add_child(eq_b)

	eq_c = GShapes.MathTexMobject.new()
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

	eq_d = GShapes.MathTexMobject.new()
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

	eq_e = GShapes.MathTexMobject.new()
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

	eq_f = GShapes.MathTexMobject.new()
	eq_f.set_expressions([
		"\\operatorname{Var}(X)=\\mathbb{E}[X^2]-\\mathbb{E}[X]^2",
		"\\overline{x}=\\frac{1}{n}\\sum_{i=1}^{n}x_i+\\unknowncmd{z}"
	])
	eq_f.multiline = true
	eq_f.align_mode = &"left"
	eq_f.font_size = 30
	eq_f.color = Color(0.74, 0.96, 1.0)
	eq_f.position = Vector2(740.0, 330.0)
	eq_f.modulate.a = 0.0
	add_child(eq_f)

	eq_g = GShapes.MathTexMobject.new()
	eq_g.set_expressions([
		"\\left\\{ f(x)=\\frac{\\sqrt[3]{x^2+1}}{1+x} \\right\\}",
		"\\binom{n}{k}=\\frac{n!}{k!(n-k)!}",
		"\\operatorname{argmax}_x\\; g(x)=\\mathcal{F}(x)"
	])
	eq_g.multiline = true
	eq_g.multiline_align_separator = true
	eq_g.multiline_separator_token = "="
	eq_g.multiline_separator_padding = 1
	eq_g.align_mode = &"left"
	eq_g.font_size = 28
	eq_g.color = Color(0.9, 0.95, 1.0)
	eq_g.position = Vector2(740.0, 480.0)
	eq_g.modulate.a = 0.0
	add_child(eq_g)

	play(GShapes.Write.new(eq_a, 1.1, &"linear"))
	wait(0.25)
	play(GShapes.TransformMatchingText.new(
		eq_a,
		eq_b,
		1.0,
		&"smooth",
		24.0
	))
	wait(0.25)
	play(GShapes.FadeIn.new(eq_c, 0.8, &"smooth"))
	wait(0.2)
	play(GShapes.Write.new(eq_d, 0.9, &"linear"))
	wait(0.2)
	play(GShapes.TransformMatchingText.new(
		eq_d,
		eq_e,
		1.0,
		&"smooth",
		16.0
	))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_f, 0.7, &"smooth"))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_g, 0.75, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



