# Demo: MixedMobjectParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var svg_obj: GShapesSvgMobject
var image_obj: GShapesImageMobject
var trail: GShapesPolylineMobject
var tracker: GShapesValueTracker


func _ready() -> void:
	_create_caption("Phase 6 mobject parity: SVG + image adapters + path primitive")

	trail = GShapes.PolylineMobject.new()
	trail.position = Vector2(140.0, 260.0)
	trail.stroke_width = 3.0
	trail.color = Color(0.55, 0.82, 1.0)
	trail.set_points(PackedVector2Array([
		Vector2(0.0, 180.0),
		Vector2(220.0, 40.0),
		Vector2(480.0, 220.0),
		Vector2(780.0, 80.0),
	]))
	trail.set_draw_progress(0.0)
	add_child(trail)

	svg_obj = GShapes.SvgMobject.new()
	svg_obj.svg_path = "res://icon.svg"
	svg_obj.fit_size = Vector2(86.0, 86.0)
	svg_obj.color = Color.GOLD
	svg_obj.position = trail.to_global(trail.points[0]) + Vector2(0.0, -90.0)
	add_child(svg_obj)

	image_obj = GShapes.ImageMobject.new()
	image_obj.set_texture(_make_checker_texture(96, 96))
	image_obj.fit_size = Vector2(86.0, 86.0)
	image_obj.keep_aspect = false
	image_obj.color = Color(0.95, 1.0, 1.0, 0.92)
	image_obj.position = trail.to_global(trail.points[0]) + Vector2(0.0, 90.0)
	add_child(image_obj)

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)
	svg_obj.add_updater(_update_svg_position)
	image_obj.add_updater(_update_image_position)

	play(GShapes.ShowCreation.new(trail, 1.2, &"smooth"))
	play([
		GShapes.FadeIn.new(svg_obj, 0.5, &"smooth"),
		GShapes.FadeIn.new(image_obj, 0.5, &"smooth"),
	])
	wait(0.2)
	play(tracker.animate.set_value(1.0).set_run_time(2.0).set_rate_func(&"smooth"))
	wait(0.2)
	play([
		svg_obj.animate.set_color(Color.ORANGE_RED).scale_to(1.15),
		image_obj.animate.set_opacity(0.55).rotate_to(deg_to_rad(25.0)),
	], 0.9, &"overshoot")


func _update_svg_position(target: GShapesObject2D, _delta: float) -> void:
	var t: float = tracker.get_value()
	var local_point: Vector2 = GShapes.PathUtils.sample_polyline(trail.points, t, false)
	target.position = trail.to_global(local_point) + Vector2(0.0, -90.0)


func _update_image_position(target: GShapesObject2D, _delta: float) -> void:
	var t: float = clampf(tracker.get_value() + 0.12, 0.0, 1.0)
	var local_point: Vector2 = GShapes.PathUtils.sample_polyline(trail.points, t, false)
	target.position = trail.to_global(local_point) + Vector2(0.0, 90.0)


func _make_checker_texture(width: int, height: int) -> Texture2D:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var checker_x: int = int(floor(float(x) / 12.0))
			var checker_y: int = int(floor(float(y) / 12.0))
			var dark: bool = ((checker_x + checker_y) % 2) == 0
			var c: Color = Color(0.18, 0.23, 0.33) if dark else Color(0.8, 0.9, 1.0)
			image.set_pixel(x, y, c)
	return ImageTexture.create_from_image(image)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




