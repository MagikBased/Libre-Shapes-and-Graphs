class_name ImplicitFunction2D
extends PortObject2D

var _axes: GraphAxes2D
var axes: GraphAxes2D:
	get:
		return _axes
	set(value):
		_axes = value
		recompute_segments()
var function_name: StringName = &"circle"
var stroke_width: float = 2.0
var _grid_resolution: int = 80
var grid_resolution: int:
	get:
		return _grid_resolution
	set(value):
		_grid_resolution = maxi(8, value)
		recompute_segments()
var draw_progress: float = 1.0

var _segments: Array[PackedVector2Array] = []


func _ready() -> void:
	recompute_segments()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func recompute_segments() -> void:
	_segments.clear()
	if axes == null:
		queue_redraw()
		return

	var n: int = maxi(8, grid_resolution)
	for ix in range(n - 1):
		for iy in range(n - 1):
			var x0: float = lerpf(axes.x_min, axes.x_max, float(ix) / float(n - 1))
			var x1: float = lerpf(axes.x_min, axes.x_max, float(ix + 1) / float(n - 1))
			var y0: float = lerpf(axes.y_min, axes.y_max, float(iy) / float(n - 1))
			var y1: float = lerpf(axes.y_min, axes.y_max, float(iy + 1) / float(n - 1))

			var f00: float = _eval_f(x0, y0)
			var f10: float = _eval_f(x1, y0)
			var f01: float = _eval_f(x0, y1)
			var f11: float = _eval_f(x1, y1)

			var crossings: Array[Vector2] = []
			_add_edge_crossing(crossings, Vector2(x0, y0), Vector2(x1, y0), f00, f10)
			_add_edge_crossing(crossings, Vector2(x1, y0), Vector2(x1, y1), f10, f11)
			_add_edge_crossing(crossings, Vector2(x1, y1), Vector2(x0, y1), f11, f01)
			_add_edge_crossing(crossings, Vector2(x0, y1), Vector2(x0, y0), f01, f00)

			if crossings.size() >= 2:
				for i in range(0, crossings.size() - 1, 2):
					var a: Vector2 = axes.graph_to_local(crossings[i])
					var b: Vector2 = axes.graph_to_local(crossings[i + 1])
					_segments.append(PackedVector2Array([a, b]))

	queue_redraw()


func _draw() -> void:
	if _segments.is_empty():
		return
	var max_idx: int = int(floor(float(_segments.size()) * draw_progress))
	max_idx = clampi(max_idx, 0, _segments.size())
	for i in range(max_idx):
		var seg: PackedVector2Array = _segments[i]
		draw_line(seg[0], seg[1], color, stroke_width)


func _add_edge_crossing(crossings: Array[Vector2], a: Vector2, b: Vector2, fa: float, fb: float) -> void:
	if (fa > 0.0 and fb > 0.0) or (fa < 0.0 and fb < 0.0):
		return
	var denom: float = fb - fa
	var t: float = 0.5 if is_zero_approx(denom) else clampf(-fa / denom, 0.0, 1.0)
	crossings.append(a.lerp(b, t))


func _eval_f(x: float, y: float) -> float:
	match String(function_name).to_lower():
		"circle":
			return x * x + y * y - 4.0
		"lemniscate":
			var a2: float = 4.0
			return (x * x + y * y) * (x * x + y * y) - 2.0 * a2 * (x * x - y * y)
		"heart":
			var v: float = x * x + y * y - 1.0
			return v * v * v - x * x * y * y * y
		_:
			return x * x + y * y - 4.0
