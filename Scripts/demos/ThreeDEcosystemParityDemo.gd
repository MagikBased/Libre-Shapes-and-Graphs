# Demo: ThreeDEcosystemParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var surface: LsgSurfaceMesh3D
var cloud: LsgPointCloud3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.38, -0.34, 11.4)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.03
	axes.tip_radius = 0.09
	axes.tip_height = 0.24
	axes.show_negative_axes = true
	add_child(axes)

	surface = GShapes.SurfaceMesh3D.new()
	surface.surface_name = &"saddle"
	surface.x_min = -2.6
	surface.x_max = 2.6
	surface.z_min = -2.6
	surface.z_max = 2.6
	surface.x_steps = 52
	surface.z_steps = 52
	surface.position = Vector3(0.0, -0.2, 0.0)
	add_child(surface)

	var surface_mat := StandardMaterial3D.new()
	surface_mat.albedo_color = Color(0.22, 0.62, 0.98)
	surface_mat.roughness = 0.38
	surface.material_override = surface_mat

	cloud = GShapes.PointCloud3D.new()
	cloud.cloud_name = &"sphere"
	cloud.x_steps = 18
	cloud.z_steps = 14
	cloud.point_scale = 0.042
	cloud.point_color = Color(1.0, 0.68, 0.28)
	cloud.position = Vector3(0.0, 0.95, 0.0)
	add_child(cloud)

	var cloud_mat := StandardMaterial3D.new()
	cloud_mat.albedo_color = cloud.point_color
	cloud_mat.emission_enabled = true
	cloud_mat.emission = cloud.point_color * 0.3
	cloud.material_override = cloud_mat

	var bounds := AABB(Vector3(-4.2, -2.3, -4.2), Vector3(8.4, 5.2, 8.4))
	frame_aabb(bounds, 1.1)

	_create_overlay()


func _process(delta: float) -> void:
	time_accum += delta
	surface.rotation.y += delta * 0.24
	cloud.rotation.y -= delta * 0.4
	cloud.position.y = 0.95 + sin(time_accum * 0.85) * 0.24
	axes.rotation.y = sin(time_accum * 0.35) * 0.1


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			var bounds := AABB(Vector3(-4.2, -2.3, -4.2), Vector3(8.4, 5.2, 8.4))
			frame_aabb(bounds, 1.1)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "3D ecosystem parity: axes + surface + point cloud | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
