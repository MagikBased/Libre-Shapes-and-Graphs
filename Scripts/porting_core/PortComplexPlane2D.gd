class_name PortComplexPlane2D
extends Node2D

var unit_size: float = 84.0
var extent_units_x: int = 6
var extent_units_y: int = 4
var grid_color: Color = Color(0.58, 0.78, 1.0, 0.33)
var axis_color: Color = Color(0.92, 0.95, 1.0, 0.88)
var line_width: float = 1.1
var axis_width: float = 2.1


func _draw() -> void:
	var max_x: int = maxi(1, extent_units_x)
	var max_y: int = maxi(1, extent_units_y)
	var width_px: float = float(max_x) * unit_size
	var height_px: float = float(max_y) * unit_size

	for x in range(-max_x, max_x + 1):
		var px: float = float(x) * unit_size
		var c: Color = axis_color if x == 0 else grid_color
		var w: float = axis_width if x == 0 else line_width
		draw_line(Vector2(px, -height_px), Vector2(px, height_px), c, w, true)

	for y in range(-max_y, max_y + 1):
		var py: float = float(y) * unit_size
		var c: Color = axis_color if y == 0 else grid_color
		var w: float = axis_width if y == 0 else line_width
		draw_line(Vector2(-width_px, py), Vector2(width_px, py), c, w, true)


func complex_to_point(real_value: float, imag_value: float) -> Vector2:
	return Vector2(real_value * unit_size, -imag_value * unit_size)


func point_to_complex(point: Vector2) -> Vector2:
	return Vector2(point.x / unit_size, -point.y / unit_size)
