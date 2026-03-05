# Demo: ThreeDLineGraphParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var axes: GShapesAxes3D
var graph3d: GShapesLineGraph3D
var mover: MeshInstance3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"helix", &"lissajous", &"spiral", &"figure8"]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.36, -0.23, 12.0)
	set_camera_fov(69.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 4.0
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	graph3d = GShapes.LineGraph3D.new()
	graph3d.curve_name = modes[mode_index]
	graph3d.sample_count = 150
	graph3d.t_min = -PI
	graph3d.t_max = PI
	graph3d.curve_scale = 1.0
	graph3d.thickness = 0.075
	graph3d.line_color = Color(0.36, 0.9, 1.0, 0.88)
	add_child(graph3d)

	mover = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	mover.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.66, 0.3)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.2
	mover.material_override = mat
	add_child(mover)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.2) * 0.08
	graph3d.phase = time_accum * 0.9
	if (int(floor(time_accum * 0.55)) % 2) == 0:
		graph3d.rebuild()
	_update_mover()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_SPACE:
			_cycle_mode()
		elif key.keycode == KEY_1:
			_set_mode(0)
		elif key.keycode == KEY_2:
			_set_mode(1)
		elif key.keycode == KEY_3:
			_set_mode(2)
		elif key.keycode == KEY_4:
			_set_mode(3)
		elif key.keycode == KEY_F:
			_frame_all()


func _update_mover() -> void:
	var points: Array[Vector3] = graph3d.get_points()
	if points.is_empty():
		return
	var idx: int = int(floor(fposmod(time_accum * 24.0, float(points.size()))))
	mover.position = points[idx]
	mover.rotate_y(0.08)


func _cycle_mode() -> void:
	if modes.is_empty():
		return
	mode_index = (mode_index + 1) % modes.size()
	_apply_mode()


func _set_mode(idx: int) -> void:
	if idx < 0 or idx >= modes.size():
		return
	mode_index = idx
	_apply_mode()


func _apply_mode() -> void:
	graph3d.curve_name = modes[mode_index]
	graph3d.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, graph3d, mover]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(69.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D line-graph parity: GShapesLineGraph3D | Space/1/2/3/4 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)




