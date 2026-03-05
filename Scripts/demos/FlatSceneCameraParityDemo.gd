# Demo: FlatSceneCameraParityDemo
# Expected behavior: 2D graph content rendered on a 3D plane with orbit/pan camera controls.

extends GShapesFlatScene3D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var marker: Circle
var marker_line: Line
var marker_label: Label
var phase_t: float = 0.0


func _ready() -> void:
	canvas_size = Vector2i(1280, 720)
	pixels_per_unit = 160.0
	orthographic_size = 4.2
	use_orthographic_projection = true
	super._ready()

	target_point = Vector3.ZERO
	set_orbit_pose(0.0, -0.1, 8.5)
	frame_canvas(1.08)

	_build_flat_2d_content()
	_build_overlay()


func _process(delta: float) -> void:
	phase_t += delta
	_update_marker()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			frame_canvas(1.08)
		elif key.keycode == KEY_P:
			set_projection_mode_orthographic(not use_orthographic_projection)


func _build_flat_2d_content() -> void:
	var root: Node2D = get_canvas_root()
	if root == null:
		return

	axes = GraphAxes2D.new()
	axes.viewport_size = Vector2(1100.0, 600.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -3.6
	axes.y_max = 3.6
	axes.position = Vector2(90.0, 60.0)
	axes.axis_color = Color(0.87, 0.93, 1.0)
	axes.grid_color = Color(0.2, 0.3, 0.4, 0.45)
	axes.tick_color = Color(0.84, 0.92, 1.0)
	axes.add_coordinate_labels(14, false)
	root.add_child(axes)

	graph = FunctionPlot2D.new()
	graph.axes = axes
	graph.function_name = &"sin"
	graph.stroke_width = 4.0
	graph.color = Color(0.34, 0.86, 1.0)
	axes.add_child(graph)

	marker_line = Line.new()
	marker_line.start_point = Vector2.ZERO
	marker_line.end_point = Vector2.ZERO
	marker_line.line_type = Line.LineType.LINEAR
	marker_line.stroke_width = 2.0
	marker_line.color = Color(1.0, 0.79, 0.44)
	axes.add_child(marker_line)

	marker = Circle.new()
	marker.size = Vector2(14.0, 14.0)
	marker.color = Color(1.0, 0.56, 0.26)
	axes.add_child(marker)

	marker_label = Label.new()
	marker_label.add_theme_font_size_override("font_size", 18)
	marker_label.modulate = Color(0.98, 0.92, 0.78)
	axes.add_child(marker_label)

	_update_marker()


func _update_marker() -> void:
	if axes == null or graph == null or marker == null or marker_line == null or marker_label == null:
		return
	var x_value: float = sin(phase_t * 0.65) * 5.2
	var y_value: float = graph.eval_y(x_value)
	var p: Vector2 = graph.get_point_at_x(x_value)

	marker.position = p
	marker_line.set_endpoints(axes.c2p(0.0, 0.0), p)
	marker_label.text = "x=%.2f, y=%.2f" % [x_value, y_value]
	marker_label.position = p + Vector2(12.0, -30.0)


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "Flat 2D-in-3D parity: RMB orbit, MMB pan, wheel zoom, R reset, F frame canvas, P toggle ortho/perspective"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)



