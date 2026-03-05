class_name GShapesPolylineMobject
extends GShapesObject2D

var points: PackedVector2Array = PackedVector2Array()
var stroke_width: float = 3.0
var closed: bool = false
var draw_progress: float = 1.0


func set_points(new_points: PackedVector2Array) -> void:
	points = new_points
	queue_redraw()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if points.size() < 2:
		return
	var max_segments: int = points.size() if closed else points.size() - 1
	var draw_segments: int = maxi(0, int(floor(float(max_segments) * draw_progress)))
	if draw_segments <= 0:
		return

	for i in range(draw_segments):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		draw_line(a, b, color, stroke_width)



