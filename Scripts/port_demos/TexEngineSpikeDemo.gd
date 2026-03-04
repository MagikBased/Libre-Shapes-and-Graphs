# Demo: TexEngineSpikeDemo
# Expected behavior: Exercises Phase 9.1 TeX external-toolchain integration spike with safe fallback.

extends PortCompatibleScene

var title_label: Label
var status_label: Label
var detail_label: Label
var cache_label: Label
var equation: PortMathTexMobject


func _ready() -> void:
	_create_labels()

	equation = PortMathTexMobject.new()
	equation.tex_engine_mode = PortTexMobject.TexEngineMode.EXTERNAL_SPIKE_AUTO
	equation.set_expressions([
		"\\begin{aligned} \\mathcal{L}(\\theta) &= \\sum_{i=1}^{n} \\log p_\\theta(x_i) \\\\ \\nabla_\\theta \\mathcal{L}(\\theta) &= \\frac{1}{n}\\sum_{i=1}^{n} \\frac{\\partial}{\\partial \\theta} \\log p_\\theta(x_i) \\end{aligned}",
		"\\int_{-\\infty}^{\\infty} e^{-x^2}\\,dx = \\sqrt{\\pi}"
	])
	equation.multiline = true
	equation.align_mode = &"left"
	equation.font_size = 34
	equation.color = Color(0.86, 0.96, 1.0)
	equation.position = Vector2(32.0, 120.0)
	add_child(equation)

	# Trigger one deterministic same-input rerender so cache behavior is visible
	# when external toolchain execution succeeds.
	var snapshot_source: String = equation.tex_source
	equation.tex_source = snapshot_source
	var report: Dictionary = equation.get_last_engine_report()
	_update_status_from_report(report)
	_layout_labels()

	var root_viewport := get_viewport()
	if root_viewport != null:
		root_viewport.size_changed.connect(_layout_labels)

	play(PortWrite.new(equation, 1.2, &"linear"))


func _create_labels() -> void:
	title_label = Label.new()
	title_label.text = "Phase 9.1/9.2 TeX Engine Spike"
	title_label.modulate = Color(0.94, 0.98, 1.0)
	title_label.add_theme_font_size_override("font_size", 32)
	add_child(title_label)

	status_label = Label.new()
	status_label.modulate = Color(0.82, 0.95, 0.86)
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(status_label)

	detail_label = Label.new()
	detail_label.modulate = Color(0.95, 0.9, 0.72)
	detail_label.add_theme_font_size_override("font_size", 16)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(detail_label)

	cache_label = Label.new()
	cache_label.modulate = Color(0.74, 0.9, 1.0)
	cache_label.add_theme_font_size_override("font_size", 15)
	cache_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	add_child(cache_label)


func _update_status_from_report(report: Dictionary) -> void:
	var mode_name: String = equation.get_tex_engine_mode_name()
	var ok: bool = bool(report.get("ok", false))
	var engine_name: String = str(report.get("engine", "subset"))
	var display_mode: String = str(report.get("display_mode", "subset"))
	status_label.text = "mode=%s | ok=%s | engine=%s | display=%s" % [mode_name, str(ok), engine_name, display_mode]

	if report.has("artifact_svg_path"):
		detail_label.text = "artifact_svg=%s" % str(report.get("artifact_svg_path", ""))
		return

	var reason: String = str(report.get("reason", "no details"))
	var probe_variant: Variant = report.get("probe", {})
	var probe: Dictionary = {}
	if probe_variant is Dictionary:
		probe = probe_variant as Dictionary
	var latex_ok: bool = bool(probe.get("latex_ok", false))
	var dvisvgm_ok: bool = bool(probe.get("dvisvgm_ok", false))
	detail_label.text = "reason=%s | probe(latex=%s,dvisvgm=%s)" % [reason, str(latex_ok), str(dvisvgm_ok)]

	var cache_hit: bool = bool(report.get("cache_hit", false))
	var cache_key: String = str(report.get("cache_key", "none"))
	var cache_stats: Dictionary = PortTexToolchainSpike.get_cache_stats()
	var cache_hits: int = int(cache_stats.get("hits", 0))
	var cache_misses: int = int(cache_stats.get("misses", 0))
	cache_label.text = "cache_hit=%s | cache_key=%s | cache_stats(hits=%d,misses=%d)" % [
		str(cache_hit),
		cache_key.substr(0, mini(12, cache_key.length())),
		cache_hits,
		cache_misses
	]


func _layout_labels() -> void:
	var view_size: Vector2 = get_viewport_rect().size
	var width: float = maxf(680.0, view_size.x)
	title_label.position = Vector2(16.0, 12.0)
	title_label.size = Vector2(width - 32.0, 40.0)
	status_label.position = Vector2(16.0, 56.0)
	status_label.size = Vector2(width - 32.0, 28.0)
	detail_label.position = Vector2(16.0, 82.0)
	detail_label.size = Vector2(width - 32.0, 34.0)
	cache_label.position = Vector2(16.0, 110.0)
	cache_label.size = Vector2(width - 32.0, 30.0)
