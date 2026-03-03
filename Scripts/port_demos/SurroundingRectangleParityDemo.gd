# Demo: SurroundingRectangleParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var labels: Array[PortTextMobject] = []
var highlight: PortSurroundingRectangle2D
var active_index: int = 0


func _ready() -> void:
	_create_caption("Phase 6 surrounding rectangle parity: auto-fit highlight around text")
	_build_labels()

	highlight = PortSurroundingRectangle2D.new(labels[0], Vector2(20.0, 10.0))
	highlight.color = Color(0.45, 0.95, 1.0, 0.24)
	highlight.follow_target = true
	add_child(highlight)

	_run_sequence()


func _build_labels() -> void:
	var lines := [
		"Porting parity",
		"Layout + transforms",
		"Graph + text + motion",
		"Coverage and regression"
	]
	for i in range(lines.size()):
		var t := PortTextMobject.new()
		t.text = lines[i]
		t.font_size = 44
		t.color = Color(0.92, 0.96, 1.0)
		t.position = Vector2(280.0, 190.0 + float(i) * 110.0)
		add_child(t)
		labels.append(t)


func _run_sequence() -> void:
	for i in range(labels.size()):
		_focus_index(i)
		wait(0.25)
		play(labels[i].animate.shift(Vector2(230.0, 0.0)).set_run_time(0.55).set_rate_func(&"smooth"))
		wait(0.15)
		play(labels[i].animate.shift(Vector2(-230.0, 0.0)).set_run_time(0.55).set_rate_func(&"smooth"))
		wait(0.1)


func _focus_index(index: int) -> void:
	active_index = clampi(index, 0, labels.size() - 1)
	highlight.set_target(labels[active_index])
	play(PortFadeToColor.new(labels[active_index], labels[active_index].color, Color(0.5, 0.9, 1.0), 0.25, &"smooth"))
	wait(0.05)
	play(PortFadeToColor.new(labels[active_index], labels[active_index].color, Color(0.92, 0.96, 1.0), 0.25, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
