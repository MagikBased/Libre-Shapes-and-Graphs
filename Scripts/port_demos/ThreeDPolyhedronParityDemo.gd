# Demo: ThreeDPolyhedronParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var poly: PortPolyhedron3D
var satellites: Array[MeshInstance3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.35, -0.24, 10.8)
	set_camera_fov(67.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	poly = PortPolyhedron3D.new()
	poly.polyhedron_name = &"tetra"
	poly.radius = 1.4
	poly.surface_color = Color(0.34, 0.9, 1.0, 0.9)
	add_child(poly)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = poly.surface_color
	mat.roughness = 0.32
	mat.metallic = 0.14
	poly.material_override = mat

	_spawn_satellites()
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.28) * 0.08
	poly.rotation.y += delta * 0.66
	poly.rotation.x = sin(time_accum * 0.5) * 0.2
	poly.scale = Vector3.ONE * (1.0 + 0.08 * sin(time_accum * 1.3))

	for i in range(satellites.size()):
		var s: MeshInstance3D = satellites[i]
		var a: float = time_accum * (0.8 + float(i) * 0.1) + float(i) * 0.9
		var r: float = 2.3 + 0.16 * sin(time_accum + float(i))
		s.position = Vector3(cos(a) * r, 0.35 + sin(a * 1.5) * 0.75, sin(a) * r)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			poly.polyhedron_name = &"tetra"
			poly.rebuild()
		elif key.keycode == KEY_2:
			poly.polyhedron_name = &"octa"
			poly.rebuild()
		elif key.keycode == KEY_3:
			poly.polyhedron_name = &"icosa"
			poly.rebuild()
		elif key.keycode == KEY_F:
			_frame_all()


func _spawn_satellites() -> void:
	for i in range(5):
		var node := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.11
		sphere.height = 0.22
		node.mesh = sphere
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.07 + float(i) * 0.11, 0.72, 0.98)
		mat.emission_enabled = true
		mat.emission = mat.albedo_color * 0.2
		node.material_override = mat
		add_child(node)
		satellites.append(node)


func _frame_all() -> void:
	var nodes: Array = [axes, poly]
	for s in satellites:
		nodes.append(s)
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(67.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D polyhedron parity: PortPolyhedron3D | 1 tetra, 2 octa, 3 icosa, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
