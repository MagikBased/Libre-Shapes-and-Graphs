class_name LsgArrow2D
extends LsgObject2D

var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.RIGHT * 160.0
var stroke_width: float = 4.0
var tip_length: float = 18.0
var tip_angle_deg: float = 28.0
var draw_progress: float = 1.0


func set_points(p_start: Vector2, p_end: Vector2) -> void:
	start_point = p_start
	end_point = p_end
	queue_redraw()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var delta: Vector2 = end_point - start_point
	var total_length: float = delta.length()
	if total_length <= 0.0001:
		return

	var visible_end: Vector2 = start_point.lerp(end_point, draw_progress)
	draw_line(start_point, visible_end, color, stroke_width)

	if draw_progress < 0.999:
		return

	var dir: Vector2 = (end_point - start_point).normalized()
	if dir.length_squared() <= 0.000001:
		return

	var base_angle: float = dir.angle()
	var side_angle: float = deg_to_rad(tip_angle_deg)
	var left_dir: Vector2 = Vector2(cos(base_angle + PI - side_angle), sin(base_angle + PI - side_angle))
	var right_dir: Vector2 = Vector2(cos(base_angle + PI + side_angle), sin(base_angle + PI + side_angle))

	var left_tip: Vector2 = end_point + left_dir * tip_length
	var right_tip: Vector2 = end_point + right_dir * tip_length
	draw_line(end_point, left_tip, color, stroke_width)
	draw_line(end_point, right_tip, color, stroke_width)
