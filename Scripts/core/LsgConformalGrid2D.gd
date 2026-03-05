class_name LsgConformalGrid2D
extends Node2D

var bounds: Rect2 = Rect2(Vector2(-420.0, -240.0), Vector2(840.0, 480.0))
var major_step: float = 60.0
var samples_per_line: int = 44
var mode_name: StringName = &"twist"
var strength: float = 0.35
var line_color: Color = Color(0.58, 0.82, 1.0, 0.48)
var axis_color: Color = Color(0.95, 0.97, 1.0, 0.88)
var line_width: float = 1.1
var axis_width: float = 2.0

var _horizontal: Array[PackedVector2Array] = []
var _vertical: Array[PackedVector2Array] = []


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	_horizontal.clear()
	_vertical.clear()
	if major_step <= 0.0:
		queue_redraw()
		return

	var x_count: int = maxi(1, int(floor(bounds.size.x / major_step)))
	var y_count: int = maxi(1, int(floor(bounds.size.y / major_step)))
	var cols: int = x_count + 1
	var rows: int = y_count + 1
	var sample_count: int = maxi(2, samples_per_line)

	for row in range(rows):
		var y: float = bounds.position.y + float(row) * major_step
		var line_h := PackedVector2Array()
		line_h.resize(sample_count)
		for i in range(sample_count):
			var t: float = float(i) / float(sample_count - 1)
			var x: float = lerpf(bounds.position.x, bounds.position.x + bounds.size.x, t)
			line_h[i] = _map_point(Vector2(x, y))
		_horizontal.append(line_h)

	for col in range(cols):
		var x: float = bounds.position.x + float(col) * major_step
		var line_v := PackedVector2Array()
		line_v.resize(sample_count)
		for i in range(sample_count):
			var t: float = float(i) / float(sample_count - 1)
			var y: float = lerpf(bounds.position.y, bounds.position.y + bounds.size.y, t)
			line_v[i] = _map_point(Vector2(x, y))
		_vertical.append(line_v)

	queue_redraw()


func _map_point(p: Vector2) -> Vector2:
	var x: float = p.x / 220.0
	var y: float = p.y / 220.0
	var s: float = strength

	match String(mode_name).to_lower():
		"shear":
			return Vector2(
				p.x + (y * 110.0 * s),
				p.y + (x * 35.0 * s)
			)
		"bulge":
			var r2: float = x * x + y * y
			var factor: float = 1.0 + s * 0.65 * exp(-r2 * 0.7)
			return p * factor
		"wave":
			return Vector2(
				p.x + sin(y * 2.6) * 48.0 * s,
				p.y + cos(x * 2.1) * 36.0 * s
			)
		"twist":
			var radius: float = maxf(0.001, sqrt(x * x + y * y))
			var angle: float = atan2(y, x) + s * 0.95 * exp(-radius * 0.9)
			var r_px: float = radius * 220.0
			return Vector2(cos(angle), sin(angle)) * r_px
		_:
			return p


func _draw() -> void:
	for line in _horizontal:
		if line.size() >= 2:
			draw_polyline(line, line_color, line_width, true)
	for line in _vertical:
		if line.size() >= 2:
			draw_polyline(line, line_color, line_width, true)

	var center_x := _map_point(Vector2(0.0, bounds.position.y))
	var center_x2 := _map_point(Vector2(0.0, bounds.position.y + bounds.size.y))
	draw_line(center_x, center_x2, axis_color, axis_width, true)

	var center_y := _map_point(Vector2(bounds.position.x, 0.0))
	var center_y2 := _map_point(Vector2(bounds.position.x + bounds.size.x, 0.0))
	draw_line(center_y, center_y2, axis_color, axis_width, true)
