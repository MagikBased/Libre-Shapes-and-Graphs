# Demo: ThreeDDashedLineParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var movers: Array[MeshInstance3D] = []
var connectors: Array[LsgDashedLine3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.34, -0.26, 10.8)
	set_camera_fov(69.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.5
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_spawn_movers()
	_spawn_connectors()
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.35) * 0.08

	for i in range(movers.size()):
		var mover: MeshInstance3D = movers[i]
		var phase: float = time_accum + float(i) * 1.6
		mover.position = Vector3(
			cos(phase * (0.72 + float(i) * 0.08)) * (1.6 + float(i) * 0.55),
			0.38 + sin(phase * (1.18 + float(i) * 0.11)) * 0.55,
			sin(phase * (0.9 + float(i) * 0.09)) * (1.9 + float(i) * 0.5)
		)
		mover.rotate_y(delta * (0.7 + float(i) * 0.25))

	_update_connectors()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _spawn_movers() -> void:
	var colors: Array[Color] = [
		Color(1.0, 0.62, 0.34),
		Color(0.45, 0.95, 1.0),
		Color(0.66, 1.0, 0.54),
	]
	for i in range(colors.size()):
		var body := MeshInstance3D.new()
		if i % 2 == 0:
			var sphere := SphereMesh.new()
			sphere.radius = 0.17
			sphere.height = 0.34
			body.mesh = sphere
		else:
			var box := BoxMesh.new()
			box.size = Vector3(0.32, 0.32, 0.32)
			body.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = colors[i]
		mat.roughness = 0.36
		mat.emission_enabled = true
		mat.emission = colors[i] * 0.18
		body.material_override = mat
		add_child(body)
		movers.append(body)


func _spawn_connectors() -> void:
	var pairs: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 0)]
	for i in range(pairs.size()):
		var line: LsgDashedLine3D = GShapes.DashedLine3D.new()
		line.dash_length = 0.28
		line.gap_length = 0.18
		line.thickness = 0.03
		line.line_color = Color.from_hsv(0.08 + float(i) * 0.18, 0.7, 0.96)
		add_child(line)
		connectors.append(line)
	_update_connectors()


func _update_connectors() -> void:
	if movers.size() < 3 or connectors.size() < 3:
		return
	var c0: LsgDashedLine3D = connectors[0]
	var c1: LsgDashedLine3D = connectors[1]
	var c2: LsgDashedLine3D = connectors[2]
	c0.set_points(c0.to_local(movers[0].global_position), c0.to_local(movers[1].global_position))
	c1.set_points(c1.to_local(movers[1].global_position), c1.to_local(movers[2].global_position))
	c2.set_points(c2.to_local(movers[2].global_position), c2.to_local(movers[0].global_position))


func _frame_all() -> void:
	var nodes: Array = [axes]
	for m in movers:
		nodes.append(m)
	for c in connectors:
		nodes.append(c)
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(69.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D dashed-line parity: LsgDashedLine3D connectors | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
