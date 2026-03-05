# Demo: ThreeDSphericalGridParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var sphere_grid: LsgSphericalGrid3D
var markers: Array[MeshInstance3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.0, 0.0)
	set_orbit_pose(0.42, -0.24, 10.8)
	set_camera_fov(66.0)

	sphere_grid = GShapes.SphericalGrid3D.new()
	sphere_grid.radius = 2.15
	sphere_grid.latitude_count = 12
	sphere_grid.longitude_count = 18
	sphere_grid.angular_segments = 84
	sphere_grid.major_latitude_step = 2
	sphere_grid.major_longitude_step = 3
	add_child(sphere_grid)

	_spawn_markers()
	_create_overlay()
	_frame_scene()


func _process(delta: float) -> void:
	time_accum += delta
	sphere_grid.rotation.y += delta * 0.24
	sphere_grid.rotation.x = sin(time_accum * 0.35) * 0.12

	for i in range(markers.size()):
		var marker: MeshInstance3D = markers[i]
		var t: float = time_accum * (0.56 + float(i) * 0.1)
		var r: float = 2.25 + sin(time_accum * (0.9 + float(i) * 0.17)) * 0.16
		var lon: float = t + float(i) * 0.92
		var lat: float = sin(t * 0.73 + float(i) * 0.35) * 0.85
		marker.position = Vector3(
			cos(lon) * cos(lat) * r,
			sin(lat) * r,
			sin(lon) * cos(lat) * r
		)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_scene()


func _spawn_markers() -> void:
	for i in range(4):
		var mesh_instance := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.12
		mesh.height = 0.24
		mesh_instance.mesh = mesh

		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.07 + float(i) * 0.17, 0.72, 0.98)
		mat.roughness = 0.34
		mat.emission_enabled = true
		mat.emission = mat.albedo_color * 0.2
		mesh_instance.material_override = mat

		add_child(mesh_instance)
		markers.append(mesh_instance)


func _frame_scene() -> void:
	var nodes: Array = [sphere_grid]
	for marker in markers:
		nodes.append(marker)
	tween_frame_to_nodes(nodes, 1.05, 0.82)
	tween_fov_to(66.0, 0.82)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D spherical-grid parity: LsgSphericalGrid3D + orbital markers | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
