class_name Graph
extends GShapesObject2D

var data_points: PackedVector2Array = PackedVector2Array()
var line_color: Color = Color.BLUE
var line_width: float = 3.0
var draw_progress: float = 1.0


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()

func _draw():
	if data_points.size() < 2:
		return

	var max_segment := int(floor((float(data_points.size() - 1)) * draw_progress))
	max_segment = clampi(max_segment, 0, data_points.size() - 1)
	for i in range(max_segment):
		draw_line(data_points[i], data_points[i + 1], line_color, line_width)

