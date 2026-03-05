class_name GShapesPolarPlane2D
extends Node2D

var max_radius: float = 260.0
var radial_step: float = 52.0
var spoke_count: int = 16
var grid_color: Color = Color(0.55, 0.75, 1.0, 0.35)
var axis_color: Color = Color(0.92, 0.95, 1.0, 0.85)
var line_width: float = 1.2
var axis_width: float = 2.2


func _draw() -> void:
	if max_radius <= 0.0:
		return

	var ring_count: int = maxi(1, int(floor(max_radius / maxf(1.0, radial_step))))
	for i in range(1, ring_count + 1):
		var r: float = minf(max_radius, float(i) * radial_step)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 96, grid_color, line_width, true)

	var spokes: int = maxi(4, spoke_count)
	for i in range(spokes):
		var theta: float = TAU * (float(i) / float(spokes))
		var dir := Vector2(cos(theta), sin(theta))
		draw_line(Vector2.ZERO, dir * max_radius, grid_color, line_width, true)

	draw_line(Vector2(-max_radius, 0.0), Vector2(max_radius, 0.0), axis_color, axis_width, true)
	draw_line(Vector2(0.0, -max_radius), Vector2(0.0, max_radius), axis_color, axis_width, true)


func polar_to_point(radius_value: float, theta: float) -> Vector2:
	return Vector2(cos(theta), sin(theta)) * radius_value


func point_to_polar(point: Vector2) -> Vector2:
	return Vector2(point.length(), atan2(point.y, point.x))



