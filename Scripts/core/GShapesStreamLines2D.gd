class_name GShapesStreamLines2D
extends Node2D

var field_name: StringName = &"swirl"
var field_source: Callable
var strength: float = 1.0
var bounds: Rect2 = Rect2(Vector2(-420.0, -240.0), Vector2(840.0, 480.0))
var seed_step: float = 70.0
var steps_per_line: int = 44
var step_size: float = 0.085
var line_width: float = 1.8
var color: Color = Color(0.56, 0.88, 1.0, 0.7)
var max_magnitude: float = 2.6

var _lines: Array[PackedVector2Array] = []


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	_lines.clear()
	if seed_step <= 0.0:
		queue_redraw()
		return

	var x_count: int = maxi(1, int(floor(bounds.size.x / seed_step)))
	var y_count: int = maxi(1, int(floor(bounds.size.y / seed_step)))

	for iy in range(y_count + 1):
		for ix in range(x_count + 1):
			var seed_point := Vector2(
				bounds.position.x + float(ix) * seed_step,
				bounds.position.y + float(iy) * seed_step
			)
			var line := _build_line(seed_point)
			if line.size() >= 2:
				_lines.append(line)

	queue_redraw()


func _build_line(seed_point: Vector2) -> PackedVector2Array:
	var backward: PackedVector2Array = _integrate(seed_point, -1.0)
	var forward: PackedVector2Array = _integrate(seed_point, 1.0)
	var out := PackedVector2Array()
	for i in range(backward.size() - 1, -1, -1):
		out.append(backward[i])
	for i in range(1, forward.size()):
		out.append(forward[i])
	return out


func _integrate(start: Vector2, direction: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var p := start
	out.append(p)
	for i in range(steps_per_line):
		var v: Vector2 = _sample_field(p) * direction
		var mag: float = v.length()
		if mag <= 0.0001:
			break
		if mag > max_magnitude:
			v = v.normalized() * max_magnitude
		p += v * step_size * 120.0
		if not bounds.has_point(p):
			break
		out.append(p)
	return out


func _sample_field(p: Vector2) -> Vector2:
	if field_source.is_valid():
		var v: Variant = field_source.call(p)
		if v is Vector2:
			return (v as Vector2) * strength

	var px: float = p.x / 220.0
	var py: float = p.y / 220.0
	match String(field_name).to_lower():
		"radial":
			return Vector2(px, py) * strength
		"saddle":
			return Vector2(px, -py) * strength
		"sinus":
			return Vector2(sin(py * 2.2), cos(px * 1.8)) * strength
		"swirl":
			return Vector2(-py, px) * strength
		_:
			return Vector2(-py, px) * strength


func _draw() -> void:
	for line in _lines:
		if line.size() >= 2:
			draw_polyline(line, color, line_width, true)



