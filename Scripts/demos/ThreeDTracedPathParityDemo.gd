# Demo: ThreeDTracedPathParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var axes: GShapesAxes3D
var mover_a: MeshInstance3D
var mover_b: MeshInstance3D
var trail_a: GShapesTracedPath3D
var trail_b: GShapesTracedPath3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.38, -0.3, 12.0)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	mover_a = _create_mover(Color(1.0, 0.66, 0.28), 0.18)
	mover_b = _create_mover(Color(0.42, 0.95, 1.0), 0.15)

	trail_a = _create_trail(Color(1.0, 0.66, 0.28), 0.07, 900)
	trail_a.set_target(mover_a)
	trail_b = _create_trail(Color(0.42, 0.95, 1.0), 0.06, 700)
	trail_b.set_target(mover_b)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.35) * 0.08
	mover_a.position = Vector3(
		cos(time_accum * 0.95) * 2.3,
		sin(time_accum * 1.45) * 1.0,
		sin(time_accum * 1.12) * 2.0
	)
	mover_b.position = Vector3(
		cos(time_accum * 1.2 + 1.0) * 1.7,
		cos(time_accum * 1.55 + 0.2) * 0.95,
		sin(time_accum * 0.82 + 0.8) * 2.4
	)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_C:
			trail_a.clear_trace()
			trail_b.clear_trace()
		elif key.keycode == KEY_F:
			_frame_all()


func _create_mover(color: Color, radius: float) -> MeshInstance3D:
	var body := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	body.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.36
	mat.emission_enabled = true
	mat.emission = color * 0.2
	body.material_override = mat
	add_child(body)
	return body


func _create_trail(color: Color, width_value: float, max_points_value: int) -> GShapesTracedPath3D:
	var trail: GShapesTracedPath3D = GShapes.TracedPath3D.new()
	trail.width = width_value
	trail.default_color = color
	trail.min_distance = 0.03
	trail.max_points = max_points_value
	trail.local_space = true
	trail.enabled_tracing = true
	add_child(trail)
	return trail


func _frame_all() -> void:
	var nodes: Array = [axes, mover_a, mover_b]
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(70.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D traced-path parity: animated GShapesTracedPath3D trails | RMB orbit, MMB pan, wheel zoom, R reset, F reframe, C clear"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)



