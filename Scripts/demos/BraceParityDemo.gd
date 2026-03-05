# Demo: BraceParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var terms: Array[GShapesTextMobject] = []
var brace: GShapesBrace2D
var brace_label: GShapesTextMobject


func _ready() -> void:
	_create_caption("Phase 6 brace parity: brace and label tracking for grouped terms")
	_build_equation_terms()
	_build_brace()
	_run_focus_sequence()


func _build_equation_terms() -> void:
	var parts := [
		"f(x)",
		"=",
		"x^2",
		"+",
		"2x",
		"+",
		"1",
	]
	var start := Vector2(250.0, 300.0)
	for i in range(parts.size()):
		var t: GShapesTextMobject = GShapes.TextMobject.new()
		t.text = parts[i]
		t.font_size = 60
		t.position = start + Vector2(float(i) * 110.0, 0.0)
		t.color = Color(0.9, 0.95, 1.0)
		add_child(t)
		terms.append(t)


func _build_brace() -> void:
	brace = GShapes.Brace2D.new(terms[2], GShapes.Brace2D.BraceSide.BOTTOM)
	brace.color = Color(0.42, 0.94, 1.0)
	brace.padding = 14.0
	brace.span_extra = 20.0
	brace.minimum_span = 84.0
	brace.brace_depth = 28.0
	brace.stroke_width = 3.0
	add_child(brace)

	brace_label = GShapes.TextMobject.new()
	brace_label.text = "quadratic term"
	brace_label.font_size = 34
	brace_label.color = Color(0.62, 0.95, 1.0)
	add_child(brace_label)
	brace_label.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		(target as Node2D).global_position = brace.get_label_anchor(20.0) + Vector2(-110.0, 0.0)
	)


func _run_focus_sequence() -> void:
	_focus_term(2, "quadratic term")
	wait(0.2)
	play(terms[2].animate.shift(Vector2(0.0, -50.0)).set_run_time(0.55))
	wait(0.1)
	play(terms[2].animate.shift(Vector2(0.0, 50.0)).set_run_time(0.55))

	wait(0.2)
	_focus_term(4, "linear term")
	play(terms[4].animate.shift(Vector2(0.0, -50.0)).set_run_time(0.55))
	wait(0.1)
	play(terms[4].animate.shift(Vector2(0.0, 50.0)).set_run_time(0.55))

	wait(0.2)
	_focus_term(6, "constant term")
	play(terms[6].animate.shift(Vector2(0.0, -50.0)).set_run_time(0.55))
	wait(0.1)
	play(terms[6].animate.shift(Vector2(0.0, 50.0)).set_run_time(0.55))


func _focus_term(index: int, label_text: String) -> void:
	var i: int = clampi(index, 0, terms.size() - 1)
	brace.set_target(terms[i])
	brace_label.text = label_text
	play(GShapes.FadeToColor.new(terms[i], terms[i].color, Color(0.44, 0.95, 1.0), 0.22, &"smooth"))
	wait(0.04)
	play(GShapes.FadeToColor.new(terms[i], terms[i].color, Color(0.9, 0.95, 1.0), 0.22, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




