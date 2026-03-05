# Demo: VectorFieldParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var field: LsgVectorField2D
var strength_tracker: LsgValueTracker
var strength_label: LsgDecimalNumber


func _ready() -> void:
	_create_caption("Phase 6 vector-field parity: sampled arrow field with animated strength")

	strength_tracker = GShapes.ValueTracker.new(0.8)
	add_child(strength_tracker)

	field = GShapes.VectorField2D.new()
	field.position = Vector2(640.0, 360.0)
	field.x_min = -5.0
	field.x_max = 5.0
	field.y_min = -3.0
	field.y_max = 3.0
	field.step = 1.0
	field.arrow_scale = 70.0
	field.max_vector_length = 1.5
	field.function_name = &"swirl"
	field.arrow_color = Color(0.52, 0.94, 1.0)
	add_child(field)

	field.add_child(_make_crosshair())
	field.set_strength(strength_tracker.get_value())

	strength_label = GShapes.DecimalNumber.new(strength_tracker.get_value(), 2, false, "")
	strength_label.font_size = 36
	strength_label.position = Vector2(560.0, 110.0)
	strength_label.color = Color(0.65, 1.0, 0.92)
	strength_label.set_value_source(func(): return strength_tracker.get_value())
	add_child(strength_label)

	play_sequence([
		GShapes.SetValue.new(strength_tracker, 1.6, 1.5, &"smooth"),
		GShapes.SetValue.new(strength_tracker, 0.45, 1.4, &"smooth"),
		GShapes.SetValue.new(strength_tracker, 1.2, 1.4, &"linear"),
	])


func _process(_delta: float) -> void:
	if field == null or strength_tracker == null:
		return
	field.strength = strength_tracker.get_value()


func _make_crosshair() -> Node2D:
	var root := Node2D.new()
	var x_line := Line.new()
	x_line.color = Color(0.8, 0.9, 1.0, 0.25)
	x_line.stroke_width = 2.0
	x_line.set_endpoints(Vector2(-380.0, 0.0), Vector2(380.0, 0.0))
	root.add_child(x_line)

	var y_line := Line.new()
	y_line.color = Color(0.8, 0.9, 1.0, 0.25)
	y_line.stroke_width = 2.0
	y_line.set_endpoints(Vector2(0.0, -250.0), Vector2(0.0, 250.0))
	root.add_child(y_line)
	return root


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

