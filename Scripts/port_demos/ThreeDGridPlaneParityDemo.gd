# Demo: ThreeDGridPlaneParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var grid: PortGridPlane3D
var movers: Array[MeshInstance3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.36, -0.28, 11.4)
	set_camera_fov(69.0)

	grid = PortGridPlane3D.new()
	grid.x_min = -4.2
	grid.x_max = 4.2
	grid.z_min = -4.2
	grid.z_max = 4.2
	grid.y_level = -0.05
	grid.major_step = 1.0
	grid.minor_step = 0.5
	add_child(grid)

	axes = PortAxes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_spawn_movers()
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.32) * 0.08
	for i in range(movers.size()):
		var node: MeshInstance3D = movers[i]
		var phase: float = time_accum + float(i) * 1.2
		node.position = Vector3(
			cos(phase * (0.74 + float(i) * 0.1)) * (1.2 + float(i) * 0.8),
			0.32 + sin(phase * (1.25 + float(i) * 0.18)) * 0.45,
			sin(phase * (0.88 + float(i) * 0.09)) * (1.5 + float(i) * 0.65)
		)
		node.rotate_y(delta * (0.65 + float(i) * 0.2))


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _spawn_movers() -> void:
	for i in range(4):
		var body := MeshInstance3D.new()
		if i % 2 == 0:
			var sphere := SphereMesh.new()
			sphere.radius = 0.18
			sphere.height = 0.36
			body.mesh = sphere
		else:
			var box := BoxMesh.new()
			box.size = Vector3(0.32, 0.32, 0.32)
			body.mesh = box

		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.06 + float(i) * 0.14, 0.72, 0.96)
		mat.roughness = 0.38
		mat.emission_enabled = true
		mat.emission = mat.albedo_color * 0.16
		body.material_override = mat
		add_child(body)
		movers.append(body)


func _frame_all() -> void:
	var nodes: Array = [grid, axes]
	for m in movers:
		nodes.append(m)
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(69.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D grid-plane parity: PortGridPlane3D + moving objects | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
