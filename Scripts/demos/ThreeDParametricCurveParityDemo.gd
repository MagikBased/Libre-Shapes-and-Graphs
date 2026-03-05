# Demo: ThreeDParametricCurveParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var axes: GShapesAxes3D
var curve: GShapesParametricCurve3D
var mover: MeshInstance3D
var trail: GShapesTracedPath3D
var mode_names: Array[StringName] = [&"helix", &"lissajous", &"trefoil", &"figure8"]
var time_accum: float = 0.0
var _last_mode_index: int = -1


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.34, -0.28, 11.8)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	curve = GShapes.ParametricCurve3D.new()
	curve.width = 0.08
	curve.default_color = Color(1.0, 0.72, 0.34)
	curve.curve_name = &"helix"
	curve.t_min = 0.0
	curve.t_max = TAU * 3.0
	curve.samples = 180
	curve.curve_scale = 1.6
	curve.center_offset = Vector3(0.0, 0.0, 0.0)
	add_child(curve)
	curve.rebuild()

	mover = _create_mover()
	trail = GShapes.TracedPath3D.new()
	trail.width = 0.05
	trail.default_color = Color(0.42, 0.95, 1.0)
	trail.min_distance = 0.04
	trail.max_points = 850
	trail.local_space = true
	trail.enabled_tracing = true
	trail.set_target(mover)
	add_child(trail)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.33) * 0.08

	var mode_index: int = int(floor(time_accum / 7.0)) % mode_names.size()
	if mode_index != _last_mode_index:
		_last_mode_index = mode_index
		curve.curve_name = mode_names[mode_index]
		trail.clear_trace()

	curve.phase = time_accum * 0.7
	curve.rebuild()

	var u: float = fposmod(time_accum * 0.12, 1.0)
	mover.position = curve.sample_at_ratio(u)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_C:
			trail.clear_trace()
		elif key.keycode == KEY_F:
			_frame_all()


func _create_mover() -> MeshInstance3D:
	var body := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	body.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.95, 1.0)
	mat.roughness = 0.34
	mat.emission_enabled = true
	mat.emission = Color(0.42, 0.95, 1.0) * 0.22
	body.material_override = mat
	add_child(body)
	return body


func _frame_all() -> void:
	var nodes: Array = [axes, curve, mover]
	tween_frame_to_nodes(nodes, 1.22, 0.85)
	tween_fov_to(70.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D parametric-curve parity: GShapesParametricCurve3D + tracer | RMB orbit, MMB pan, wheel zoom, R reset, F reframe, C clear"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)




