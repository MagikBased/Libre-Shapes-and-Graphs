# Demo: ThreeDCameraTourParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var clusters: Array[Node3D] = []
var tour: PortCameraTour3D
var tour_loops: int = 2
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.28, -0.28, 12.2)
	set_camera_fov(70.0)

	var axes := PortAxes3D.new()
	axes.axis_length = 3.5
	axes.axis_thickness = 0.025
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_create_cluster(Vector3(-3.0, 0.25, -2.3), Color(1.0, 0.6, 0.32))
	_create_cluster(Vector3(2.9, 0.4, -1.1), Color(0.45, 0.92, 1.0))
	_create_cluster(Vector3(0.25, 0.15, 3.2), Color(0.63, 1.0, 0.58))

	_create_overlay()
	_build_and_play_tour()


func _process(delta: float) -> void:
	time_accum += delta
	for i in range(clusters.size()):
		var cluster: Node3D = clusters[i]
		cluster.rotate_y(delta * (0.36 + float(i) * 0.12))
		cluster.position.y = 0.2 + sin(time_accum * (0.8 + float(i) * 0.2) + float(i)) * 0.12


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_T:
			_build_and_play_tour()
		elif key.keycode == KEY_F:
			_frame_all()


func _create_cluster(center: Vector3, color: Color) -> void:
	var root := Node3D.new()
	root.position = center
	add_child(root)
	clusters.append(root)

	for i in range(5):
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

		var t: float = TAU * float(i) / 5.0
		body.position = Vector3(cos(t) * 0.72, sin(float(i)) * 0.16, sin(t) * 0.72)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color.lightened(float(i) * 0.05)
		mat.roughness = 0.38
		body.material_override = mat
		root.add_child(body)


func _build_and_play_tour() -> void:
	tour = PortCameraTour3D.new()
	tour.add_step(0.20, -0.24, 5.8, clusters[0].global_position, 58.0, 0.85)
	tour.add_hold(0.25)
	tour.add_step(0.86, -0.22, 6.0, clusters[1].global_position, 60.0, 0.85)
	tour.add_hold(0.25)
	tour.add_step(-0.58, -0.20, 5.9, clusters[2].global_position, 59.0, 0.85)
	tour.add_hold(0.3)
	tour.add_step(0.28, -0.30, 12.0, Vector3.ZERO, 70.0, 1.0)
	tour.play(self, tour_loops)


func _frame_all() -> void:
	var nodes: Array = []
	for c in clusters:
		nodes.append(c)
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(70.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D camera-tour parity: PortCameraTour3D sequence | RMB orbit, MMB pan, wheel zoom, R reset, T replay tour, F frame-all"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
