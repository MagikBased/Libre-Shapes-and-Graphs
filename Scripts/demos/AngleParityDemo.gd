# Demo: AngleParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var pivot: Circle
var ray_a_tip: Circle
var ray_b_tip: Circle
var angle_arc: GShapesAngle2D
var angle_label: GShapesDecimalNumber
var theta_tracker: GShapesValueTracker


func _ready() -> void:
	_create_caption("Phase 6 angle parity: dynamic angle arc + degree readout")

	var center := Vector2(640.0, 360.0)
	theta_tracker = GShapes.ValueTracker.new(deg_to_rad(25.0))
	add_child(theta_tracker)

	pivot = _make_dot(center, Color(0.95, 0.96, 1.0), 16.0)
	ray_a_tip = _make_dot(center + Vector2(220.0, 0.0), Color(0.95, 0.8, 0.3), 12.0)
	ray_b_tip = _make_dot(center + Vector2(170.0, -120.0), Color(0.4, 0.95, 1.0), 12.0)

	var ray_a := Line.new()
	ray_a.color = Color(0.95, 0.8, 0.3)
	ray_a.stroke_width = 4.0
	add_child(ray_a)
	ray_a.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		(target as Line).set_endpoints(pivot.position, ray_a_tip.position)
	)

	var ray_b := Line.new()
	ray_b.color = Color(0.4, 0.95, 1.0)
	ray_b.stroke_width = 4.0
	add_child(ray_b)
	ray_b.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		(target as Line).set_endpoints(pivot.position, ray_b_tip.position)
	)

	ray_b_tip.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		var t := theta_tracker.get_value()
		var r := 220.0
		(target as Node2D).position = pivot.position + Vector2(cos(t), -sin(t)) * r
	)

	angle_arc = GShapes.Angle2D.new(pivot, ray_a_tip, ray_b_tip)
	angle_arc.color = Color(0.45, 1.0, 0.85)
	angle_arc.radius = 72.0
	angle_arc.stroke_width = 4.0
	add_child(angle_arc)

	angle_label = GShapes.DecimalNumber.new(0.0, 1, false, " deg")
	angle_label.font_size = 34
	angle_label.color = Color(0.62, 1.0, 0.9)
	add_child(angle_label)
	angle_label.set_value_source(func():
		return rad_to_deg(absf(theta_tracker.get_value()))
	)
	angle_label.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		(target as Node2D).global_position = angle_arc.get_label_anchor(26.0) + Vector2(-44.0, -16.0)
	)

	play_sequence([
		GShapes.SetValue.new(theta_tracker, deg_to_rad(95.0), 1.3, &"smooth"),
		GShapes.SetValue.new(theta_tracker, deg_to_rad(145.0), 1.3, &"smooth"),
		GShapes.SetValue.new(theta_tracker, deg_to_rad(40.0), 1.3, &"smooth"),
	])


func _make_dot(pos: Vector2, c: Color, diameter: float) -> Circle:
	var dot := Circle.new()
	dot.size = Vector2.ONE * diameter
	dot.color = c
	dot.position = pos
	add_child(dot)
	return dot


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




