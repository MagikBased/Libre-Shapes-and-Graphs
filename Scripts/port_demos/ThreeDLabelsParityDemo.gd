# Demo: ThreeDLabelsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var movers: Array[MeshInstance3D] = []
var labels: Array[PortLabel3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.3, 0.0)
	set_orbit_pose(0.36, -0.28, 11.6)
	set_camera_fov(69.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.6
	axes.axis_thickness = 0.025
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_spawn_mover_with_label("A", Color(1.0, 0.62, 0.32))
	_spawn_mover_with_label("B", Color(0.45, 0.95, 1.0))
	_spawn_mover_with_label("C", Color(0.64, 1.0, 0.55))

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.34) * 0.08

	for i in range(movers.size()):
		var node: MeshInstance3D = movers[i]
		var phase: float = time_accum + float(i) * 1.4
		node.position = Vector3(
			cos(phase * (0.8 + float(i) * 0.12)) * (1.6 + float(i) * 0.45),
			sin(phase * (1.2 + float(i) * 0.16)) * 0.9 + 0.2,
			sin(phase * (0.95 + float(i) * 0.08)) * (1.9 + float(i) * 0.35)
		)
		node.rotate_y(delta * (0.7 + float(i) * 0.2))


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _spawn_mover_with_label(name_tag: String, color: Color) -> void:
	var body := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.17
	sphere.height = 0.34
	body.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.36
	mat.emission_enabled = true
	mat.emission = color * 0.2
	body.material_override = mat
	add_child(body)
	movers.append(body)

	var label := PortLabel3D.new()
	label.text_color = color.lightened(0.18)
	label.outline_color = Color(0.03, 0.04, 0.08, 0.95)
	label.anchor_offset = Vector3(0.0, 0.32, 0.0)
	label.set_target(body)
	label.set_text_callable(func() -> String:
		var p: Vector3 = body.global_position
		return "%s (%.2f, %.2f, %.2f)" % [name_tag, p.x, p.y, p.z]
	)
	add_child(label)
	labels.append(label)


func _frame_all() -> void:
	var nodes: Array = [axes]
	for m in movers:
		nodes.append(m)
	for l in labels:
		nodes.append(l)
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(69.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D labels parity: PortLabel3D target/text tracking | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
