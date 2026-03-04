# Demo: ThreeDTubePathParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var tube: PortTubePath3D
var mover: MeshInstance3D
var axes: PortAxes3D
var time_accum: float = 0.0
var sample_count: int = 140
var path_turns: float = 3.2


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.38, -0.22, 11.2)
	set_camera_fov(67.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.9
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	tube = PortTubePath3D.new()
	tube.radius = 0.1
	tube.radial_segments = 12
	tube.path_color = Color(0.36, 0.9, 1.0, 0.88)
	add_child(tube)

	mover = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.14
	sphere.height = 0.28
	mover.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.62, 0.26)
	mat.roughness = 0.34
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.2
	mover.material_override = mat
	add_child(mover)

	_rebuild_path(0.0)
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.28) * 0.09

	var phase: float = time_accum * 0.7
	_rebuild_path(phase)
	mover.position = _curve_position(phase + TAU * 0.18)
	mover.rotate_y(delta * 0.95)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _rebuild_path(phase: float) -> void:
	var points: Array[Vector3] = []
	for i in range(sample_count):
		var t: float = float(i) / float(maxi(1, sample_count - 1))
		var a: float = t * TAU * path_turns + phase
		points.append(_curve_position(a))
	tube.set_points(points)


func _curve_position(a: float) -> Vector3:
	return Vector3(
		cos(a) * (2.0 + 0.35 * cos(a * 2.0)),
		sin(a * 1.9) * 1.05,
		sin(a) * (1.8 + 0.25 * sin(a * 1.6))
	)


func _frame_all() -> void:
	var nodes: Array = [axes, tube, mover]
	tween_frame_to_nodes(nodes, 1.2, 0.85)
	tween_fov_to(67.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D tube-path parity: PortTubePath3D thick path mesh | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
