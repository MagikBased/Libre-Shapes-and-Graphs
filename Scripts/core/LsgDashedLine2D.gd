class_name LsgDashedLine2D
extends LsgObject2D

var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.RIGHT * 200.0
var dash_length: float = 18.0
var gap_length: float = 10.0
var stroke_width: float = 3.0
var draw_progress: float = 1.0


func set_endpoints(p_start: Vector2, p_end: Vector2) -> void:
	start_point = p_start
	end_point = p_end
	queue_redraw()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var delta := end_point - start_point
	var total_length := delta.length()
	if total_length <= 0.0001:
		return

	var unit := delta / total_length
	var visible_length := total_length * draw_progress
	var period := maxf(0.001, dash_length + gap_length)
	var cursor := 0.0
	while cursor < visible_length:
		var dash_start := cursor
		var dash_end := minf(cursor + maxf(0.0, dash_length), visible_length)
		if dash_end > dash_start:
			var a := start_point + unit * dash_start
			var b := start_point + unit * dash_end
			draw_line(a, b, color, stroke_width)
		cursor += period
