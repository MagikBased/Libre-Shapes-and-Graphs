class_name GraphAxes2D
extends PortObject2D

var _x_min: float = -6.0
var x_min: float:
	get:
		return _x_min
	set(value):
		_x_min = value
		_on_axes_config_changed()
var _x_max: float = 6.0
var x_max: float:
	get:
		return _x_max
	set(value):
		_x_max = value
		_on_axes_config_changed()
var _y_min: float = -4.0
var y_min: float:
	get:
		return _y_min
	set(value):
		_y_min = value
		_on_axes_config_changed()
var _y_max: float = 4.0
var y_max: float:
	get:
		return _y_max
	set(value):
		_y_max = value
		_on_axes_config_changed()

var _viewport_size: Vector2 = Vector2(960.0, 540.0)
var viewport_size: Vector2:
	get:
		return _viewport_size
	set(value):
		_viewport_size = Vector2(maxf(1.0, value.x), maxf(1.0, value.y))
		_on_axes_config_changed()
var _axis_color: Color = Color(0.85, 0.9, 1.0)
var axis_color: Color:
	get:
		return _axis_color
	set(value):
		_axis_color = value
		queue_redraw()
var _grid_color: Color = Color(0.25, 0.3, 0.4, 0.45)
var grid_color: Color:
	get:
		return _grid_color
	set(value):
		_grid_color = value
		queue_redraw()
var _axis_width: float = 2.5
var axis_width: float:
	get:
		return _axis_width
	set(value):
		_axis_width = maxf(0.1, value)
		queue_redraw()
var _grid_width: float = 1.0
var grid_width: float:
	get:
		return _grid_width
	set(value):
		_grid_width = maxf(0.1, value)
		queue_redraw()
var _tick_step_x: float = 1.0
var tick_step_x: float:
	get:
		return _tick_step_x
	set(value):
		_tick_step_x = maxf(0.0001, absf(value))
		_on_axes_config_changed()
var _tick_step_y: float = 1.0
var tick_step_y: float:
	get:
		return _tick_step_y
	set(value):
		_tick_step_y = maxf(0.0001, absf(value))
		_on_axes_config_changed()
var _tick_size: float = 8.0
var tick_size: float:
	get:
		return _tick_size
	set(value):
		_tick_size = maxf(0.0, value)
		queue_redraw()
var _tick_color: Color = Color(0.9, 0.95, 1.0)
var tick_color: Color:
	get:
		return _tick_color
	set(value):
		_tick_color = value
		queue_redraw()

var _label_layer: Node2D
var _labels_enabled: bool = false
var _labels_font_size: int = 14
var _labels_include_zero: bool = false


func _ready() -> void:
	_label_layer = Node2D.new()
	add_child(_label_layer)
	queue_redraw()


func _on_axes_config_changed() -> void:
	queue_redraw()
	if _labels_enabled:
		add_coordinate_labels(_labels_font_size, _labels_include_zero)


func graph_to_local(point: Vector2) -> Vector2:
	var x_span := maxf(0.0001, x_max - x_min)
	var y_span := maxf(0.0001, y_max - y_min)
	var nx := (point.x - x_min) / x_span
	var ny := (point.y - y_min) / y_span
	var px := nx * viewport_size.x
	var py := (1.0 - ny) * viewport_size.y
	return Vector2(px, py)


func local_to_graph(point: Vector2) -> Vector2:
	var nx := point.x / maxf(0.0001, viewport_size.x)
	var ny := 1.0 - (point.y / maxf(0.0001, viewport_size.y))
	var gx := lerpf(x_min, x_max, nx)
	var gy := lerpf(y_min, y_max, ny)
	return Vector2(gx, gy)


func c2p(x: float, y: float) -> Vector2:
	return graph_to_local(Vector2(x, y))


func p2c(local_point: Vector2) -> Vector2:
	return local_to_graph(local_point)


func get_h_line_points(local_point: Vector2) -> PackedVector2Array:
	var coords := p2c(local_point)
	var y := coords.y
	return PackedVector2Array([
		c2p(x_min, y),
		c2p(coords.x, y),
	])


func get_v_line_points(local_point: Vector2) -> PackedVector2Array:
	var coords := p2c(local_point)
	var x := coords.x
	return PackedVector2Array([
		c2p(x, y_min),
		c2p(x, coords.y),
	])


func _draw() -> void:
	_draw_grid()
	_draw_axes()


func _draw_grid() -> void:
	var x := x_min
	while x <= x_max + 0.0001:
		var a := graph_to_local(Vector2(x, y_min))
		var b := graph_to_local(Vector2(x, y_max))
		draw_line(a, b, grid_color, grid_width)
		x += tick_step_x

	var y := y_min
	while y <= y_max + 0.0001:
		var a := graph_to_local(Vector2(x_min, y))
		var b := graph_to_local(Vector2(x_max, y))
		draw_line(a, b, grid_color, grid_width)
		y += tick_step_y


func _draw_axes() -> void:
	var x0: float = clampf(0.0, x_min, x_max)
	var y0: float = clampf(0.0, y_min, y_max)

	var x_axis_a := graph_to_local(Vector2(x_min, y0))
	var x_axis_b := graph_to_local(Vector2(x_max, y0))
	draw_line(x_axis_a, x_axis_b, axis_color, axis_width)

	var y_axis_a := graph_to_local(Vector2(x0, y_min))
	var y_axis_b := graph_to_local(Vector2(x0, y_max))
	draw_line(y_axis_a, y_axis_b, axis_color, axis_width)
	_draw_ticks(x0, y0)


func _draw_ticks(x0: float, y0: float) -> void:
	var x := x_min
	while x <= x_max + 0.0001:
		var p := c2p(x, y0)
		draw_line(
			Vector2(p.x, p.y - tick_size * 0.5),
			Vector2(p.x, p.y + tick_size * 0.5),
			tick_color,
			1.0
		)
		x += tick_step_x

	var y := y_min
	while y <= y_max + 0.0001:
		var p := c2p(x0, y)
		draw_line(
			Vector2(p.x - tick_size * 0.5, p.y),
			Vector2(p.x + tick_size * 0.5, p.y),
			tick_color,
			1.0
		)
		y += tick_step_y


func clear_coordinate_labels() -> void:
	if _label_layer == null:
		return
	_labels_enabled = false
	for child in _label_layer.get_children():
		child.queue_free()


func add_coordinate_labels(font_size: int = 14, include_zero: bool = false) -> void:
	if _label_layer == null:
		return
	_labels_enabled = true
	_labels_font_size = font_size
	_labels_include_zero = include_zero
	clear_coordinate_labels()
	_labels_enabled = true

	var x0: float = clampf(0.0, x_min, x_max)
	var y0: float = clampf(0.0, y_min, y_max)

	var x := x_min
	while x <= x_max + 0.0001:
		if include_zero or absf(x) > 0.0001:
			var label := Label.new()
			label.text = str(snappedf(x, 0.01))
			label.add_theme_font_size_override("font_size", font_size)
			label.modulate = tick_color
			var p := c2p(x, y0)
			label.position = Vector2(p.x - 10.0, p.y + 8.0)
			_label_layer.add_child(label)
		x += tick_step_x

	var y := y_min
	while y <= y_max + 0.0001:
		if include_zero or absf(y) > 0.0001:
			var label := Label.new()
			label.text = str(snappedf(y, 0.01))
			label.add_theme_font_size_override("font_size", font_size)
			label.modulate = tick_color
			var p := c2p(x0, y)
			label.position = Vector2(p.x + 8.0, p.y - 10.0)
			_label_layer.add_child(label)
		y += tick_step_y


func input_to_graph_point(x: float, graph: FunctionPlot2D) -> Vector2:
	if graph == null:
		return Vector2.ZERO
	return graph.get_point_at_x(x)


func i2gp(x: float, graph: FunctionPlot2D) -> Vector2:
	return input_to_graph_point(x, graph)


func graph_to_world(point: Vector2) -> Vector2:
	return to_global(graph_to_local(point))


func world_to_graph(world_point: Vector2) -> Vector2:
	return local_to_graph(to_local(world_point))


func get_secant_line_points(graph: FunctionPlot2D, x0: float, x1: float) -> PackedVector2Array:
	if graph == null:
		return PackedVector2Array()
	var y0 := graph.eval_y(x0)
	var y1 := graph.eval_y(x1)
	return PackedVector2Array([
		c2p(x0, y0),
		c2p(x1, y1),
	])


func get_tangent_line_points(
	graph: FunctionPlot2D,
	x_value: float,
	graph_span: float = 2.0
) -> PackedVector2Array:
	if graph == null:
		return PackedVector2Array()
	var span := maxf(0.0001, absf(graph_span))
	var y := graph.eval_y(x_value)
	var m := graph.get_slope_at_x(x_value)
	var x0 := x_value - span * 0.5
	var x1 := x_value + span * 0.5
	var y0 := y + m * (x0 - x_value)
	var y1 := y + m * (x1 - x_value)
	return PackedVector2Array([
		c2p(x0, y0),
		c2p(x1, y1),
	])


func get_graph_label(
	graph: FunctionPlot2D,
	text: String,
	x_value: float = INF,
	font_size: int = 18,
	label_color: Color = Color.WHITE,
	anchor: StringName = &"auto"
) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = label_color

	if graph == null:
		label.position = Vector2(0.0, 0.0)
		return label

	var x := x_max - 0.8 if is_inf(x_value) else x_value
	var point := graph.get_point_at_x(x)
	label.position = _compute_label_position(point, label, anchor)
	return label


func _compute_label_position(point: Vector2, label: Label, anchor: StringName) -> Vector2:
	var size := label.get_minimum_size()
	var margin := Vector2(10.0, 8.0)

	match String(anchor).to_lower():
		"right":
			return point + Vector2(margin.x, -0.5 * size.y)
		"left":
			return point + Vector2(-size.x - margin.x, -0.5 * size.y)
		"up":
			return point + Vector2(-0.5 * size.x, -size.y - margin.y)
		"down":
			return point + Vector2(-0.5 * size.x, margin.y)
		_:
			# Auto anchor: prefer right/up, flip if it exits viewport bounds.
			var pos := point + Vector2(margin.x, -size.y - margin.y)
			if pos.x + size.x > viewport_size.x:
				pos.x = point.x - size.x - margin.x
			if pos.y < 0.0:
				pos.y = point.y + margin.y
			if pos.y + size.y > viewport_size.y:
				pos.y = point.y - size.y - margin.y
			return pos
