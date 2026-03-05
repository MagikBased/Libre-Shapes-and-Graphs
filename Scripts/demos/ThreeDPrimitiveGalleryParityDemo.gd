# Demo: ThreeDPrimitiveGalleryParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var left_surface: LsgSurfaceMesh3D
var right_surface: LsgSurfaceMesh3D
var center_cloud: LsgPointCloud3D
var accent_nodes: Array[Node3D] = []
var focus_groups: Array = []
var focus_index: int = -1
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.3, -0.24, 13.2)
	set_camera_fov(72.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.4
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	left_surface = _create_surface(&"wave", Vector3(-3.4, -0.4, 0.0), Color(0.26, 0.66, 0.98))
	right_surface = _create_surface(&"saddle", Vector3(3.4, -0.35, 0.0), Color(0.34, 0.92, 0.66))

	center_cloud = GShapes.PointCloud3D.new()
	center_cloud.cloud_name = &"sphere"
	center_cloud.x_steps = 16
	center_cloud.z_steps = 12
	center_cloud.point_scale = 0.042
	center_cloud.point_color = Color(1.0, 0.74, 0.34)
	center_cloud.position = Vector3(0.0, 1.35, 0.0)
	add_child(center_cloud)
	var cloud_mat := StandardMaterial3D.new()
	cloud_mat.albedo_color = center_cloud.point_color
	cloud_mat.emission_enabled = true
	cloud_mat.emission = center_cloud.point_color * 0.3
	center_cloud.material_override = cloud_mat

	_spawn_accents()
	_build_focus_groups()
	_create_overlay()
	_frame_all()
	_run_timeline()


func _process(delta: float) -> void:
	time_accum += delta
	left_surface.rotation.y += delta * 0.2
	right_surface.rotation.y -= delta * 0.16
	center_cloud.rotation.y += delta * 0.3
	center_cloud.position.y = 1.35 + sin(time_accum * 0.85) * 0.2
	for i in range(accent_nodes.size()):
		var node: Node3D = accent_nodes[i]
		var base_angle: float = TAU * float(i) / float(maxi(1, accent_nodes.size()))
		var radius: float = 2.45 + sin(time_accum * 0.75 + float(i) * 0.4) * 0.14
		node.position = Vector3(cos(base_angle + time_accum * 0.14) * radius, 0.25 + sin(time_accum + float(i)) * 0.09, sin(base_angle + time_accum * 0.14) * radius)
		node.rotate_y(delta * 0.9)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			_focus_group(0)
		elif key.keycode == KEY_2:
			_focus_group(1)
		elif key.keycode == KEY_3:
			_focus_group(2)
		elif key.keycode == KEY_0:
			_frame_all()
		elif key.keycode == KEY_C:
			_cycle_focus()


func _create_surface(surface_type: StringName, pos: Vector3, color: Color) -> LsgSurfaceMesh3D:
	var surface: LsgSurfaceMesh3D = GShapes.SurfaceMesh3D.new()
	surface.surface_name = surface_type
	surface.x_steps = 52
	surface.z_steps = 52
	surface.position = pos
	add_child(surface)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.36
	surface.material_override = mat
	return surface


func _spawn_accents() -> void:
	for i in range(7):
		var body := MeshInstance3D.new()
		if i % 2 == 0:
			var sphere := SphereMesh.new()
			sphere.radius = 0.2
			sphere.height = 0.4
			body.mesh = sphere
		else:
			var box := BoxMesh.new()
			box.size = Vector3(0.34, 0.34, 0.34)
			body.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.04 + float(i) * 0.1, 0.7, 0.95)
		mat.roughness = 0.42
		body.material_override = mat
		add_child(body)
		accent_nodes.append(body)


func _build_focus_groups() -> void:
	focus_groups = []
	focus_groups.append([left_surface])
	focus_groups.append([right_surface])
	focus_groups.append([center_cloud])


func _run_timeline() -> void:
	var chain: Tween = create_tween()
	chain.set_parallel(false)
	chain.tween_interval(0.2)
	chain.tween_callback(func(): _focus_group(0))
	chain.tween_interval(1.0)
	chain.tween_callback(func(): _focus_group(1))
	chain.tween_interval(1.0)
	chain.tween_callback(func(): _focus_group(2))
	chain.tween_interval(1.0)
	chain.tween_callback(func():
		GShapes.Effects3D.staggered_pulse(self, accent_nodes, 0.05, 1.22, 0.45)
	)
	chain.tween_interval(0.8)
	chain.tween_callback(func(): _frame_all())


func _focus_group(group_idx: int) -> void:
	if group_idx < 0 or group_idx >= focus_groups.size():
		return
	focus_index = group_idx
	var nodes: Array = focus_groups[group_idx]
	tween_frame_to_nodes(nodes, 1.35, 0.75)
	tween_fov_to(62.0, 0.75)


func _frame_all() -> void:
	focus_index = -1
	var nodes: Array = [left_surface, right_surface, center_cloud]
	for n in accent_nodes:
		nodes.append(n)
	tween_frame_to_nodes(nodes, 1.2, 0.85)
	tween_fov_to(72.0, 0.85)


func _cycle_focus() -> void:
	if focus_groups.is_empty():
		return
	var next_index: int = (focus_index + 1) % focus_groups.size()
	_focus_group(next_index)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D primitive gallery parity: 1/2/3 focus, 0 all, C cycle | RMB orbit, MMB pan, wheel zoom, R reset"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
