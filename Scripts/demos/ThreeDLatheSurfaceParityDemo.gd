# Demo: ThreeDLatheSurfaceParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var axes: GShapesAxes3D
var lathe: GShapesLatheSurface3D
var marker: MeshInstance3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.34, -0.24, 10.9)
	set_camera_fov(67.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	lathe = GShapes.LatheSurface3D.new()
	lathe.profile_name = &"vase"
	lathe.profile_steps = 46
	lathe.angle_segments = 64
	lathe.radius_scale = 1.45
	lathe.height_scale = 3.4
	lathe.surface_color = Color(0.3, 0.88, 1.0, 0.9)
	add_child(lathe)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = lathe.surface_color
	mat.roughness = 0.32
	mat.metallic = 0.08
	lathe.material_override = mat

	marker = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.14
	sphere.height = 0.28
	marker.mesh = sphere
	var marker_mat := StandardMaterial3D.new()
	marker_mat.albedo_color = Color(1.0, 0.64, 0.28)
	marker_mat.emission_enabled = true
	marker_mat.emission = marker_mat.albedo_color * 0.22
	marker.material_override = marker_mat
	add_child(marker)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.28) * 0.08
	lathe.rotation.y += delta * 0.42
	lathe.profile_phase = time_accum * 0.9
	lathe.radius_scale = 1.35 + sin(time_accum * 0.65) * 0.2
	lathe.rebuild()

	var ring_angle: float = time_accum * 1.2
	marker.position = Vector3(cos(ring_angle) * 1.9, 0.5 + sin(time_accum * 1.4) * 1.15, sin(ring_angle) * 1.9)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			lathe.profile_name = &"vase"
		elif key.keycode == KEY_2:
			lathe.profile_name = &"goblet"
		elif key.keycode == KEY_3:
			lathe.profile_name = &"bulb"
		elif key.keycode == KEY_F:
			_frame_all()


func _frame_all() -> void:
	var nodes: Array = [axes, lathe, marker]
	tween_frame_to_nodes(nodes, 1.2, 0.85)
	tween_fov_to(67.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D lathe-surface parity: GShapesLatheSurface3D | 1/2/3 profile, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)




