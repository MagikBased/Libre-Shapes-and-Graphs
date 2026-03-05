# Demo: ThreeDParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var surface: GShapesSurfaceMesh3D
var cloud: GShapesPointCloud3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.28, -0.36, 10.0)
	set_camera_fov(72.0)

	surface = GShapes.SurfaceMesh3D.new()
	surface.surface_name = &"ripple"
	surface.x_steps = 56
	surface.z_steps = 56
	add_child(surface)

	var surface_mat := StandardMaterial3D.new()
	surface_mat.albedo_color = Color(0.16, 0.58, 0.95)
	surface_mat.roughness = 0.34
	surface.material_override = surface_mat

	cloud = GShapes.PointCloud3D.new()
	cloud.cloud_name = &"helix"
	cloud.x_steps = 24
	cloud.z_steps = 18
	cloud.point_scale = 0.048
	cloud.point_color = Color(1.0, 0.6, 0.2)
	add_child(cloud)

	var cloud_mat := StandardMaterial3D.new()
	cloud_mat.albedo_color = cloud.point_color
	cloud_mat.emission_enabled = true
	cloud_mat.emission = cloud.point_color * 0.25
	cloud.material_override = cloud_mat

	var bounds := AABB(Vector3(-3.5, -2.2, -3.5), Vector3(7.0, 4.4, 7.0))
	frame_aabb(bounds, 1.15)

	_create_overlay()


func _process(delta: float) -> void:
	time_accum += delta
	surface.rotation.y += delta * 0.28
	cloud.rotation.y -= delta * 0.42
	cloud.position.y = sin(time_accum * 0.9) * 0.28


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			var bounds := AABB(Vector3(-3.5, -2.2, -3.5), Vector3(7.0, 4.4, 7.0))
			frame_aabb(bounds, 1.15)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "3D parity demo: RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)



