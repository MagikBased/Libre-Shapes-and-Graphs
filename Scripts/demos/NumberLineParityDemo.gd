# Demo: NumberLineParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var number_line: GShapesNumberLine2D
var tracker: GShapesValueTracker
var pointer: Circle
var value_readout: GShapesDecimalNumber


func _ready() -> void:
	_create_caption("Phase 6 number-line parity: ticks/labels + tracker-driven pointer")

	tracker = GShapes.ValueTracker.new(-4.0)
	add_child(tracker)

	number_line = GShapes.NumberLine2D.new()
	number_line.position = Vector2(200.0, 360.0)
	number_line.x_min = -4.0
	number_line.x_max = 8.0
	number_line.unit_size = 82.0
	number_line.tick_step = 1.0
	number_line.tick_size = 14.0
	number_line.stroke_width = 3.0
	number_line.label_precision = 0
	number_line.color = Color(0.84, 0.92, 1.0)
	number_line.refresh()
	add_child(number_line)

	pointer = Circle.new()
	pointer.size = Vector2(22.0, 22.0)
	pointer.color = Color(1.0, 0.84, 0.2)
	add_child(pointer)
	pointer.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		var value := tracker.get_value()
		var local := number_line.number_to_local(value)
		(target as Node2D).global_position = number_line.global_position + local + Vector2(0.0, -26.0)
	)

	value_readout = GShapes.DecimalNumber.new(tracker.get_value(), 2, true, "")
	value_readout.position = Vector2(560.0, 190.0)
	value_readout.font_size = 42
	value_readout.color = Color(0.56, 0.96, 1.0)
	value_readout.set_value_source(func(): return tracker.get_value())
	add_child(value_readout)

	play_sequence([
		GShapes.SetValue.new(tracker, 2.5, 1.5, &"smooth"),
		GShapes.SetValue.new(tracker, -1.0, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 7.25, 1.7, &"linear"),
	])


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




