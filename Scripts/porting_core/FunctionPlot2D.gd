class_name FunctionPlot2D
extends PortObject2D

var axes: GraphAxes2D:
	set(value):
		field = value
		recompute_points()
var function_name: StringName = &"sin":
	set(value):
		field = value
		recompute_points()
var stroke_width: float = 3.0
var sample_count: int = 180:
	set(value):
		field = maxi(2, value)
		recompute_points()
var draw_progress: float = 1.0
var style: StringName = &"solid":
	set(value):
		field = value
		queue_redraw()
var render_mode: StringName = &"polyline":
	set(value):
		field = value
		_prepare_render_points()
		queue_redraw()
var discontinuities: PackedFloat32Array = PackedFloat32Array():
	set(value):
		field = value
		queue_redraw()
var discontinuity_epsilon: float = 0.0005:
	set(value):
		field = maxf(0.0, value)
		queue_redraw()

var _points: PackedVector2Array = PackedVector2Array()
var _x_values: PackedFloat32Array = PackedFloat32Array()
var _render_points: PackedVector2Array = PackedVector2Array()
var _render_x_values: PackedFloat32Array = PackedFloat32Array()


func _ready() -> void:
	recompute_points()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_points() -> void:
	_points.clear()
	_x_values.clear()
	if axes == null:
		queue_redraw()
		return

	var n := maxi(2, sample_count)
	var span := axes.x_max - axes.x_min
	for i in range(n):
		var t := float(i) / float(n - 1)
		var x := axes.x_min + span * t
		var y := _eval_function(x)
		_points.append(axes.graph_to_local(Vector2(x, y)))
		_x_values.append(x)

	_prepare_render_points()
	queue_redraw()


func get_point_at_x(x: float) -> Vector2:
	if axes == null:
		return Vector2.ZERO
	var y := _eval_function(x)
	return axes.graph_to_local(Vector2(x, y))


func _eval_function(x: float) -> float:
	match String(function_name).to_lower():
		"sin":
			return sin(x)
		"cos":
			return cos(x)
		"parabola":
			return 0.15 * x * x - 1.5
		"cubic":
			return 0.03 * x * x * x - 0.6 * x
		"step":
			return 2.0 if x > 3.0 else 1.0
		_:
			return sin(x)


func _draw() -> void:
	if _render_points.size() < 2:
		return

	var max_segment := int(floor((float(_render_points.size() - 1)) * draw_progress))
	max_segment = clampi(max_segment, 0, _render_points.size() - 1)
	for i in range(max_segment):
		if _is_discontinuous_between(_render_x_values[i], _render_x_values[i + 1]):
			continue
		if String(style).to_lower() == "dashed" and i % 2 == 1:
			continue
		draw_line(_render_points[i], _render_points[i + 1], color, stroke_width)


func _is_discontinuous_between(x0: float, x1: float) -> bool:
	if discontinuities.is_empty():
		return false
	var a := minf(x0, x1)
	var b := maxf(x0, x1)
	for d in discontinuities:
		if d >= a - discontinuity_epsilon and d <= b + discontinuity_epsilon:
			return true
	return false


func _prepare_render_points() -> void:
	_render_points = _points
	_render_x_values = _x_values

	if String(render_mode).to_lower() != "smooth":
		return
	if _points.size() < 3:
		return

	var smooth_points := PackedVector2Array()
	var smooth_x := PackedFloat32Array()
	var steps := 5

	for i in range(_points.size() - 1):
		var p0 := _points[maxi(i - 1, 0)]
		var p1 := _points[i]
		var p2 := _points[i + 1]
		var p3 := _points[mini(i + 2, _points.size() - 1)]
		var x1 := _x_values[i]
		var x2 := _x_values[i + 1]

		for s in range(steps):
			var t := float(s) / float(steps)
			var pt := _catmull_rom(p0, p1, p2, p3, t)
			var xv := lerpf(x1, x2, t)
			smooth_points.append(pt)
			smooth_x.append(xv)

	smooth_points.append(_points[_points.size() - 1])
	smooth_x.append(_x_values[_x_values.size() - 1])

	_render_points = smooth_points
	_render_x_values = smooth_x


func _catmull_rom(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)
