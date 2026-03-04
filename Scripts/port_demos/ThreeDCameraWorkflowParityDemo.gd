# Demo: ThreeDCameraWorkflowParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var clusters: Array[Node3D] = []
var active_index: int = -1


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.24, -0.28, 12.0)
	set_camera_fov(70.0)

	var axes := PortAxes3D.new()
	axes.axis_length = 3.2
	axes.axis_thickness = 0.025
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_create_cluster(Vector3(-3.0, 0.2, -2.4), Color(0.95, 0.55, 0.32), 0)
	_create_cluster(Vector3(3.1, 0.3, -1.0), Color(0.45, 0.9, 1.0), 1)
	_create_cluster(Vector3(0.4, 0.2, 3.1), Color(0.6, 1.0, 0.55), 2)

	var all_nodes: Array = []
	for c in clusters:
		all_nodes.append(c)
	frame_nodes(all_nodes, 1.25)

	_create_overlay()
	_cycle_focus()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			_focus_cluster(0)
		elif key.keycode == KEY_2:
			_focus_cluster(1)
		elif key.keycode == KEY_3:
			_focus_cluster(2)
		elif key.keycode == KEY_0:
			_frame_all()
		elif key.keycode == KEY_C:
			_cycle_focus()


func _create_cluster(center: Vector3, color: Color, variant: int) -> void:
	var root := Node3D.new()
	root.position = center
	add_child(root)
	clusters.append(root)

	for i in range(4):
		var body := MeshInstance3D.new()
		if (i + variant) % 2 == 0:
			var box := BoxMesh.new()
			box.size = Vector3(0.42, 0.42, 0.42)
			body.mesh = box
		else:
			var sphere := SphereMesh.new()
			sphere.radius = 0.24
			sphere.height = 0.48
			body.mesh = sphere

		var ang: float = TAU * float(i) / 4.0
		body.position = Vector3(cos(ang) * 0.75, sin(float(i)) * 0.18, sin(ang) * 0.75)

		var mat := StandardMaterial3D.new()
		mat.albedo_color = color.lightened(float(i) * 0.04)
		mat.roughness = 0.4
		body.material_override = mat
		root.add_child(body)


func _focus_cluster(index: int) -> void:
	if index < 0 or index >= clusters.size():
		return
	active_index = index
	var target_node: Node3D = clusters[index]
	var nodes: Array = [target_node]
	tween_frame_to_nodes(nodes, 1.35, 0.8)
	tween_fov_to(62.0, 0.8)


func _frame_all() -> void:
	active_index = -1
	var nodes: Array = []
	for c in clusters:
		nodes.append(c)
	tween_frame_to_nodes(nodes, 1.25, 0.9)
	tween_fov_to(70.0, 0.9)


func _cycle_focus() -> void:
	if clusters.is_empty():
		return
	var next_index: int = (active_index + 1) % clusters.size()
	_focus_cluster(next_index)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D camera workflow parity: 1/2/3 focus cluster, 0 frame-all, C cycle | RMB orbit, MMB pan, wheel zoom, R reset"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
