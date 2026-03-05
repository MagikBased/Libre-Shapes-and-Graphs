# Demo: TransformDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var tri_a: Polygon2D
var tri_b: Polygon2D


func _ready() -> void:
	_create_caption("Transform demo: position, scale, and rotation interpolation")

	tri_a = _make_triangle(Vector2(220.0, 300.0), Color.ORANGE_RED)
	tri_b = _make_triangle(Vector2(220.0, 520.0), Color.DEEP_SKY_BLUE)

	play(GShapes.Transform.new(
		tri_a,
		Vector2(980.0, 300.0),
		Vector2(1.8, 1.8),
		deg_to_rad(220.0),
		2.2,
		&"smooth"
	))
	wait_seconds(0.4)
	play(GShapes.Transform.new(
		tri_b,
		Vector2(980.0, 520.0),
		Vector2(0.7, 0.7),
		deg_to_rad(-180.0),
		2.2,
		&"smooth"
	))


func _make_triangle(pos: Vector2, fill_color: Color) -> Polygon2D:
	var tri := Polygon2D.new()
	tri.polygon = PackedVector2Array([
		Vector2(0.0, -48.0),
		Vector2(42.0, 36.0),
		Vector2(-42.0, 36.0),
	])
	tri.position = pos
	tri.color = fill_color
	add_child(tri)
	return tri


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
