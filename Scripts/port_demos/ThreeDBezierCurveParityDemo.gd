# Demo: ThreeDBezierCurveParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var curve: PortBezierCurve3D
var control_markers: Array[MeshInstance3D] = []
var mover: MeshInstance3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.36, -0.24, 11.0)
	set_camera_fov(67.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	curve = PortBezierCurve3D.new()
	curve.curve_radius = 0.09
	curve.curve_color = Color(0.38, 0.92, 1.0, 0.88)
	add_child(curve)

	_spawn_control_markers()
	_spawn_mover()
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.28) * 0.08
	var points: Array[Vector3] = _animated_control_points(time_accum)
	curve.set_control_points(points)
	_sync_markers(points)
	_update_mover()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _animated_control_points(t: float) -> Array[Vector3]:
	return [
		Vector3(-2.2, -0.8 + sin(t * 1.1) * 0.35, -1.3 + cos(t * 0.9) * 0.25),
		Vector3(-0.7 + sin(t * 0.7) * 0.45, 1.45 + cos(t * 1.3) * 0.4, -0.95 + sin(t * 1.0) * 0.35),
		Vector3(0.75 + cos(t * 0.85) * 0.5, -1.2 + sin(t * 1.45) * 0.45, 0.9 + cos(t * 1.2) * 0.3),
		Vector3(2.25, 0.6 + sin(t * 1.05) * 0.4, 1.25 + sin(t * 0.8) * 0.28),
	]


func _spawn_control_markers() -> void:
	for i in range(4):
		var marker := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.1
		sphere.height = 0.2
		marker.mesh = sphere
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.06 + float(i) * 0.12, 0.72, 0.96)
		mat.emission_enabled = true
		mat.emission = mat.albedo_color * 0.2
		marker.material_override = mat
		add_child(marker)
		control_markers.append(marker)


func _spawn_mover() -> void:
	mover = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	mover.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.68, 0.3)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.2
	mover.material_override = mat
	add_child(mover)


func _sync_markers(points: Array[Vector3]) -> void:
	var count: int = mini(points.size(), control_markers.size())
	for i in range(count):
		control_markers[i].position = points[i]


func _update_mover() -> void:
	var samples: Array[Vector3] = curve.get_sampled_points()
	if samples.is_empty():
		return
	var idx: int = int(floor(fposmod(time_accum * 26.0, float(samples.size()))))
	mover.position = samples[idx]
	mover.rotate_y(0.08)


func _frame_all() -> void:
	var nodes: Array = [axes, curve, mover]
	for m in control_markers:
		nodes.append(m)
	tween_frame_to_nodes(nodes, 1.15, 0.83)
	tween_fov_to(67.0, 0.83)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D bezier-curve parity: PortBezierCurve3D + animated controls | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
