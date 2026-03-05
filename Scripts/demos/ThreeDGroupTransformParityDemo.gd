# Demo: ThreeDGroupTransformParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var group: LsgGroup3D
var members: Array[Node3D] = []
var time_accum: float = 0.0
var _pulse_points: Array[Vector3] = []


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.32, -0.3, 10.6)
	set_camera_fov(72.0)

	var axes: LsgAxes3D = GShapes.Axes3D.new()
	axes.axis_length = 3.0
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.07
	axes.tip_height = 0.2
	axes.show_negative_axes = false
	add_child(axes)

	group = GShapes.Group3D.new()
	add_child(group)

	_spawn_members()
	_apply_line_formation()
	_create_overlay()
	_run_group_timeline()


func _process(delta: float) -> void:
	time_accum += delta
	for i in range(members.size()):
		var node: Node3D = members[i]
		if node == null:
			continue
		var base: Vector3 = _pulse_points[i]
		node.position.y = base.y + sin(time_accum * 1.6 + float(i) * 0.55) * 0.14
		node.rotate_y(delta * (0.45 + float(i % 3) * 0.1))


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			var bounds := AABB(Vector3(-4.4, -2.0, -4.4), Vector3(8.8, 5.0, 8.8))
			frame_aabb(bounds, 1.1)


func _spawn_members() -> void:
	var count: int = 8
	for i in range(count):
		var body := MeshInstance3D.new()
		if i % 2 == 0:
			var box := BoxMesh.new()
			box.size = Vector3(0.48, 0.48, 0.48)
			body.mesh = box
		else:
			var sphere := SphereMesh.new()
			sphere.radius = 0.28
			sphere.height = 0.56
			body.mesh = sphere

		var t: float = float(i) / float(maxi(1, count - 1))
		var color := Color.from_hsv(lerpf(0.05, 0.6, t), 0.72, 0.95)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.42
		body.material_override = mat

		add_child(body)
		group.add_member(body)
		members.append(body)
		_pulse_points.append(Vector3.ZERO)


func _run_group_timeline() -> void:
	var line_positions: Array[Vector3] = group.compute_linear_positions(Vector3.RIGHT, 1.2, true)
	var grid_positions: Array[Vector3] = group.compute_grid_xz_positions(2, 4, Vector2(1.2, 1.2), true)
	var ring_positions: Array[Vector3] = _compute_ring_positions(members.size(), 2.2)

	var sequence := create_tween()
	sequence.set_parallel(false)
	sequence.tween_interval(0.25)
	sequence.tween_callback(func(): _animate_members_to(line_positions, 0.85))
	sequence.tween_interval(1.0)
	sequence.tween_callback(func(): _animate_members_to(grid_positions, 0.95))
	sequence.tween_interval(1.05)
	sequence.tween_callback(func(): _animate_members_to(ring_positions, 1.05))
	sequence.tween_interval(1.2)
	sequence.tween_callback(func(): _animate_members_to(line_positions, 0.9))


func _apply_line_formation() -> void:
	var line_positions: Array[Vector3] = group.compute_linear_positions(Vector3.RIGHT, 1.2, true)
	group.apply_positions(line_positions)
	_sync_pulse_points()


func _animate_members_to(positions: Array[Vector3], duration: float) -> void:
	var count: int = mini(members.size(), positions.size())
	for i in range(count):
		var node: Node3D = members[i]
		var tw := create_tween()
		tw.tween_interval(float(i) * 0.045)
		tw.tween_property(node, "position:x", positions[i].x, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.parallel().tween_property(node, "position:z", positions[i].z, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.parallel().tween_property(node, "rotation:y", node.rotation.y + PI * 0.8, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_points.resize(members.size())
	for i in range(count):
		_pulse_points[i] = positions[i]


func _compute_ring_positions(count: int, radius: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if count <= 0:
		return out
	for i in range(count):
		var t: float = TAU * float(i) / float(count)
		out.append(Vector3(cos(t) * radius, 0.0, sin(t) * radius))
	return out


func _sync_pulse_points() -> void:
	_pulse_points.resize(members.size())
	for i in range(members.size()):
		_pulse_points[i] = members[i].position


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "3D group/transform parity: line-grid-ring layout transitions | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
