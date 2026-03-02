# Demo: TransformMatchingShapesDemo
# Expected behavior: See PlandAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var source_poly: Polygon2D
var target_poly: Polygon2D


func _ready() -> void:
	_create_caption("TransformMatchingShapes demo: polygon morph with crossfade fallback")

	source_poly = _make_poly(PackedVector2Array([
		Vector2(0.0, -70.0),
		Vector2(62.0, 50.0),
		Vector2(-62.0, 50.0),
	]), Vector2(260.0, 340.0), Color.ORANGE_RED)

	target_poly = _make_poly(PackedVector2Array([
		Vector2(0.0, -72.0),
		Vector2(22.0, -26.0),
		Vector2(74.0, -20.0),
		Vector2(32.0, 14.0),
		Vector2(48.0, 68.0),
		Vector2(0.0, 38.0),
		Vector2(-48.0, 68.0),
		Vector2(-32.0, 14.0),
		Vector2(-74.0, -20.0),
		Vector2(-22.0, -26.0),
	]), Vector2(920.0, 340.0), Color.DEEP_SKY_BLUE)
	target_poly.modulate.a = 0.0

	play(PortTransformMatchingShapes.new(source_poly, target_poly, 1.6, &"smooth"))


func _make_poly(points: PackedVector2Array, pos: Vector2, c: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.polygon = points
	poly.position = pos
	poly.color = c
	add_child(poly)
	return poly


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
