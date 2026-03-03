# Demo: ComplexFunctionParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var tracker: PortValueTracker
var base_path: PortComplexFunctionPath2D
var mapped_path: PortComplexFunctionPath2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 complex-function parity: source curve morphing through f(z)")

	tracker = PortValueTracker.new(0.0)
	add_child(tracker)

	base_path = PortComplexFunctionPath2D.new()
	base_path.position = Vector2(640.0, 360.0)
	base_path.source_name = &"circle"
	base_path.function_name = &"square"
	base_path.domain_scale = 1.05
	base_path.output_scale = 145.0
	base_path.morph_strength = 0.0
	base_path.stroke_width = 2.0
	base_path.color = Color(0.75, 0.85, 1.0, 0.5)
	base_path.rebuild_path()
	add_child(base_path)

	mapped_path = PortComplexFunctionPath2D.new()
	mapped_path.position = base_path.position
	mapped_path.source_name = base_path.source_name
	mapped_path.function_name = base_path.function_name
	mapped_path.domain_scale = base_path.domain_scale
	mapped_path.output_scale = base_path.output_scale
	mapped_path.morph_strength = tracker.get_value()
	mapped_path.stroke_width = 3.0
	mapped_path.color = Color(1.0, 0.72, 0.35, 0.95)
	mapped_path.rebuild_path()
	add_child(mapped_path)
	_last_strength = mapped_path.morph_strength

	play(PortFadeIn.new(base_path, 0.4, &"smooth"))
	play(PortShowCreation.new(mapped_path, 0.8, &"smooth"))
	wait(0.15)
	play_sequence([
		PortSetValue.new(tracker, 0.6, 1.25, &"smooth"),
		PortSetValue.new(tracker, 1.0, 1.15, &"smooth"),
		PortSetValue.new(tracker, 0.35, 1.0, &"linear"),
	])


func _process(_delta: float) -> void:
	if tracker == null or mapped_path == null:
		return
	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.02:
		mapped_path.morph_strength = s
		mapped_path.rebuild_path()
		_last_strength = s


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
