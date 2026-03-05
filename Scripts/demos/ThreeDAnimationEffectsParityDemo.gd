# Demo: ThreeDAnimationEffectsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var surface: LsgSurfaceMesh3D
var cloud: LsgPointCloud3D
var effect_nodes: Array[Node3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.26, -0.3, 11.2)
	set_camera_fov(71.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.6
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	surface = GShapes.SurfaceMesh3D.new()
	surface.surface_name = &"wave"
	surface.x_steps = 56
	surface.z_steps = 56
	surface.position = Vector3(0.0, -0.35, 0.0)
	add_child(surface)

	var surface_mat := StandardMaterial3D.new()
	surface_mat.albedo_color = Color(0.22, 0.62, 0.96)
	surface_mat.roughness = 0.35
	surface.material_override = surface_mat

	cloud = GShapes.PointCloud3D.new()
	cloud.cloud_name = &"helix"
	cloud.x_steps = 20
	cloud.z_steps = 14
	cloud.point_scale = 0.04
	cloud.point_color = Color(1.0, 0.68, 0.32)
	cloud.position = Vector3(0.0, 1.0, 0.0)
	add_child(cloud)

	var cloud_mat := StandardMaterial3D.new()
	cloud_mat.albedo_color = cloud.point_color
	cloud_mat.emission_enabled = true
	cloud_mat.emission = cloud.point_color * 0.28
	cloud.material_override = cloud_mat

	_spawn_effect_nodes()
	_create_overlay()
	_run_effect_timeline()


func _process(delta: float) -> void:
	time_accum += delta
	surface.rotation.y += delta * 0.18
	cloud.rotation.y -= delta * 0.32
	cloud.position.y = 1.0 + sin(time_accum * 0.95) * 0.2
	for i in range(effect_nodes.size()):
		var node: Node3D = effect_nodes[i]
		node.rotate_y(delta * (0.5 + float(i) * 0.08))


func _spawn_effect_nodes() -> void:
	for i in range(5):
		var body := MeshInstance3D.new()
		if i % 2 == 0:
			var sphere := SphereMesh.new()
			sphere.radius = 0.23
			sphere.height = 0.46
			body.mesh = sphere
		else:
			var box := BoxMesh.new()
			box.size = Vector3(0.42, 0.42, 0.42)
			body.mesh = box
		var angle: float = TAU * float(i) / 5.0
		body.position = Vector3(cos(angle) * 2.1, 0.35, sin(angle) * 2.1)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color.from_hsv(0.08 + float(i) * 0.12, 0.68, 0.96)
		mat.roughness = 0.42
		body.material_override = mat
		add_child(body)
		effect_nodes.append(body)


func _run_effect_timeline() -> void:
	var chain := create_tween()
	chain.set_parallel(false)
	chain.tween_interval(0.15)
	chain.tween_callback(func(): GShapes.Effects3D.pulse_scale(self, cloud, 1.26, 0.9, 2))
	chain.tween_interval(1.0)
	chain.tween_callback(func(): GShapes.Effects3D.spin_y(self, surface, PI * 1.2, 1.0))
	chain.tween_interval(0.35)
	chain.tween_callback(func(): GShapes.Effects3D.staggered_pulse(self, effect_nodes, 0.07, 1.22, 0.46))
	chain.tween_interval(0.9)
	chain.tween_callback(func():
		if effect_nodes.size() > 0:
			GShapes.Effects3D.arc_move_to(self, effect_nodes[0], Vector3(0.0, 0.85, -2.6), 0.75, 1.1)
	)
	chain.tween_interval(0.5)
	chain.tween_callback(func():
		if effect_nodes.size() > 0:
			GShapes.Effects3D.arc_move_to(self, effect_nodes[0], Vector3(2.1, 0.35, 0.0), 0.75, 1.1)
	)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D animation/effects parity: pulse, spin, stagger, arc-move | RMB orbit, MMB pan, wheel zoom, R reset"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
