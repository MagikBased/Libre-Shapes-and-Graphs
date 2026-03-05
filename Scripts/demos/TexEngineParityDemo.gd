# Demo: TexEngineParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var eq_source: GShapesMathTexMobject
var eq_target: GShapesMathTexMobject
var eq_features: GShapesMathTexMobject
var eq_fallback: GShapesMathTexMobject
var eq_aliases: GShapesMathTexMobject
var eq_environments: GShapesMathTexMobject
var fallback_info: Label
var fallback_detail_info: Label
var caption_label: Label


func _ready() -> void:
	_create_caption("Phase 7 TeX engine parity: nesting, delimiters, matching, and fallback behavior")

	eq_source = GShapes.MathTexMobject.new()
	eq_source.set_expressions([
		"\\left\\langle v,w\\right\\rangle",
		"\\frac{\\sqrt[3]{x^2+1}}{1+x}"
	])
	eq_source.multiline = true
	eq_source.multiline_align_separator = true
	eq_source.multiline_separator_token = "="
	eq_source.align_mode = &"left"
	eq_source.font_size = 40
	eq_source.color = Color(0.62, 0.9, 1.0)
	eq_source.position = Vector2(120.0, 170.0)
	add_child(eq_source)

	eq_target = GShapes.MathTexMobject.new()
	eq_target.set_expressions([
		"\\operatorname{proj}_{w}(v)",
		"\\frac{\\left\\langle v,w\\right\\rangle}{\\left\\lVert w \\right\\rVert^2}w"
	])
	eq_target.multiline = true
	eq_target.multiline_align_separator = true
	eq_target.multiline_separator_token = "="
	eq_target.align_mode = &"left"
	eq_target.font_size = 40
	eq_target.color = Color(0.98, 0.74, 0.36)
	eq_target.position = eq_source.position
	eq_target.modulate.a = 0.0
	add_child(eq_target)

	eq_features = GShapes.MathTexMobject.new()
	eq_features.set_expressions([
		"\\binom{n}{k}=\\frac{n!}{k!(n-k)!}",
		"\\mathbb{E}[X]=\\sum_{i=1}^{n}x_i\\,p_i",
		"\\mathcal{F}(x)=\\mathbf{A}x+\\mathbf{b}",
		"\\overset{\\mathrm{def}}{=}\\frac{a+b}{c},\\;\\underset{x\\to 0}{\\lim}f(x)",
		"f(x)=0\\Rightarrow x=\\pm 1",
		"\\boxed{\\Re(z)}+\\cancel{\\Im(z)}\\iff z\\in\\mathbb{R}"
	])
	eq_features.multiline = true
	eq_features.multiline_align_separator = true
	eq_features.multiline_separator_token = "="
	eq_features.multiline_separator_tokens = PackedStringArray(["=", "\\Rightarrow"])
	eq_features.multiline_separator_padding = 1
	eq_features.align_mode = &"left"
	eq_features.font_size = 30
	eq_features.color = Color(0.86, 0.96, 1.0)
	eq_features.position = Vector2(120.0, 380.0)
	eq_features.modulate.a = 0.0
	add_child(eq_features)

	eq_fallback = GShapes.MathTexMobject.new()
	eq_fallback.set_expressions([
		"\\unknownalpha{z}+\\unknownbeta",
		"\\overline{x}=\\frac{1}{n}\\sum_{i=1}^{n}x_i"
	])
	eq_fallback.multiline = true
	eq_fallback.multiline_align_separator = true
	eq_fallback.multiline_separator_token = "="
	eq_fallback.align_mode = &"left"
	eq_fallback.font_size = 30
	eq_fallback.color = Color(1.0, 0.85, 0.55)
	eq_fallback.position = Vector2(760.0, 380.0)
	eq_fallback.modulate.a = 0.0
	add_child(eq_fallback)

	eq_aliases = GShapes.MathTexMobject.new()
	eq_aliases.set_expressions([
		"\\left.\\dfrac{a+b}{c}\\right|_{x=0}",
		"\\operatorname*{argmax}_{x}\\; \\Bigl(f(x)\\Bigr)=\\mathcal{F}(x)"
	])
	eq_aliases.multiline = true
	eq_aliases.multiline_align_separator = true
	eq_aliases.multiline_separator_token = "="
	eq_aliases.align_mode = &"left"
	eq_aliases.font_size = 28
	eq_aliases.color = Color(0.82, 0.95, 1.0)
	eq_aliases.position = Vector2(760.0, 520.0)
	eq_aliases.modulate.a = 0.0
	add_child(eq_aliases)

	eq_environments = GShapes.MathTexMobject.new()
	eq_environments.set_expressions([
		"\\begin{cases}x^2, & x \\ge 0 \\\\ -x, & x < 0\\end{cases}",
		"\\begin{bmatrix}a & b \\\\ c & d\\end{bmatrix}",
		"\\begin{aligned}f(x)&=x^2+1 \\\\ g(x)&=\\sqrt{x+1}\\end{aligned}"
	])
	eq_environments.multiline = true
	eq_environments.multiline_align_separator = true
	eq_environments.multiline_separator_token = "="
	eq_environments.align_mode = &"left"
	eq_environments.font_size = 27
	eq_environments.color = Color(0.75, 0.94, 0.85)
	eq_environments.position = Vector2(760.0, 240.0)
	eq_environments.modulate.a = 0.0
	add_child(eq_environments)

	fallback_info = Label.new()
	fallback_info.modulate = Color(1.0, 0.9, 0.72)
	fallback_info.add_theme_font_size_override("font_size", 20)
	fallback_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(fallback_info)

	fallback_detail_info = Label.new()
	fallback_detail_info.modulate = Color(0.95, 0.86, 0.68)
	fallback_detail_info.add_theme_font_size_override("font_size", 16)
	fallback_detail_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(fallback_detail_info)
	_layout_scene()

	var root_viewport := get_viewport()
	if root_viewport != null:
		root_viewport.size_changed.connect(_layout_scene)

	play(GShapes.Write.new(eq_source, 1.05, &"linear"))
	wait(0.2)
	play(GShapes.TransformMatchingText.new(
		eq_source,
		eq_target,
		1.1,
		&"smooth",
		20.0,
		PackedStringArray(["v", "w"]),
		{"\\lVert w \\rVert^2": "\\left\\lVert w \\right\\rVert^2"}
	))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_features, 0.7, &"smooth"))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_fallback, 0.7, &"smooth"))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_environments, 0.6, &"smooth"))
	wait(0.2)
	play(GShapes.FadeIn.new(eq_aliases, 0.6, &"smooth"))
	_update_fallback_info()


func _update_fallback_info() -> void:
	if eq_fallback == null or fallback_info == null or fallback_detail_info == null:
		return
	var unsupported: PackedStringArray = eq_fallback.get_last_unsupported_commands()
	if unsupported.is_empty():
		fallback_info.text = "unsupported commands: none"
	else:
		fallback_info.text = "unsupported commands: %s" % [", ".join(unsupported)]

	var per_expression: Array[PackedStringArray] = eq_fallback.get_last_expression_unsupported_commands()
	if per_expression.is_empty():
		fallback_detail_info.text = "per-expression diagnostics: none"
		return
	var lines: PackedStringArray = PackedStringArray()
	for i in range(per_expression.size()):
		var entry: PackedStringArray = per_expression[i]
		if entry.is_empty():
			lines.append("e%d:none" % [i + 1])
		else:
			lines.append("e%d:%s" % [i + 1, ",".join(entry)])
	fallback_detail_info.text = "per-expression diagnostics: %s" % [" | ".join(lines)]


func _create_caption(text: String) -> void:
	caption_label = Label.new()
	caption_label.text = text
	caption_label.position = Vector2(16.0, 12.0)
	caption_label.modulate = Color(0.9, 0.95, 1.0)
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(caption_label)


func _layout_scene() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = maxf(640.0, viewport_size.x)
	var viewport_height: float = maxf(720.0, viewport_size.y)
	var narrow: bool = viewport_width < 1320.0
	var left_x: float = 32.0
	var right_x: float = maxf(left_x + 380.0, viewport_width * 0.56)

	if caption_label != null:
		caption_label.position = Vector2(16.0, 12.0)
		caption_label.size = Vector2(viewport_width - 32.0, 56.0)
		caption_label.add_theme_font_size_override("font_size", 22 if narrow else 26)

	if eq_source != null:
		eq_source.position = Vector2(left_x, 112.0)
		eq_source.font_size = 34 if narrow else 40
	if eq_target != null:
		eq_target.position = eq_source.position
		eq_target.font_size = eq_source.font_size

	if narrow:
		var stack_start_y: float = 260.0
		var stack_end_y: float = maxf(stack_start_y + 220.0, viewport_height - 170.0)
		var stack_step: float = (stack_end_y - stack_start_y) / 3.0
		if eq_features != null:
			eq_features.position = Vector2(left_x, stack_start_y)
			eq_features.font_size = 24
		if eq_environments != null:
			eq_environments.position = Vector2(left_x, stack_start_y + stack_step)
			eq_environments.font_size = 22
		if eq_fallback != null:
			eq_fallback.position = Vector2(left_x, stack_start_y + stack_step * 2.0)
			eq_fallback.font_size = 24
		if eq_aliases != null:
			eq_aliases.position = Vector2(left_x, stack_start_y + stack_step * 3.0)
			eq_aliases.font_size = 22
	else:
		if eq_features != null:
			eq_features.position = Vector2(left_x, 380.0)
			eq_features.font_size = 30
		if eq_environments != null:
			eq_environments.position = Vector2(right_x, 240.0)
			eq_environments.font_size = 27
		if eq_fallback != null:
			eq_fallback.position = Vector2(right_x, 380.0)
			eq_fallback.font_size = 30
		if eq_aliases != null:
			eq_aliases.position = Vector2(right_x, 520.0)
			eq_aliases.font_size = 28

	_layout_diagnostics_labels(viewport_width, viewport_height)


func _layout_diagnostics_labels(viewport_width: float, viewport_height: float) -> void:
	if fallback_info == null or fallback_detail_info == null:
		return
	var left_x: float = 32.0
	var content_width: float = maxf(360.0, viewport_width - left_x - 40.0)
	var bottom_y: float = viewport_height - 78.0
	fallback_info.position = Vector2(left_x, bottom_y)
	fallback_info.size = Vector2(content_width, 34.0)
	fallback_detail_info.position = Vector2(left_x, bottom_y + 34.0)
	fallback_detail_info.size = Vector2(content_width, 44.0)



