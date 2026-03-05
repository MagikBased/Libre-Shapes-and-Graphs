# Demo: ThreeDRibbonTrailParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var mover: MeshInstance3D
var ribbon: LsgRibbonTrail3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.33, -0.28, 11.5)
	set_camera_fov(69.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	mover = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	mover.mesh = sphere
	var mover_mat := StandardMaterial3D.new()
	mover_mat.albedo_color = Color(1.0, 0.66, 0.3)
	mover_mat.roughness = 0.36
	mover_mat.emission_enabled = true
	mover_mat.emission = mover_mat.albedo_color * 0.2
	mover.material_override = mover_mat
	add_child(mover)

	ribbon = GShapes.RibbonTrail3D.new()
	ribbon.trail_width = 0.26
	ribbon.trail_color = Color(0.42, 0.94, 1.0, 0.72)
	ribbon.min_distance = 0.045
	ribbon.max_points = 520
	ribbon.local_space = true
	ribbon.set_target(mover)
	add_child(ribbon)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.33) * 0.08
	mover.position = Vector3(
		cos(time_accum * 0.88) * 2.2,
		0.35 + sin(time_accum * 1.5) * 0.9,
		sin(time_accum * 1.12) * 2.0
	)
	mover.rotate_y(delta * 0.9)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_C:
			ribbon.clear_trail()
		elif key.keycode == KEY_F:
			_frame_all()


func _frame_all() -> void:
	var nodes: Array = [axes, mover, ribbon]
	tween_frame_to_nodes(nodes, 1.25, 0.85)
	tween_fov_to(69.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D ribbon-trail parity: LsgRibbonTrail3D | RMB orbit, MMB pan, wheel zoom, R reset, F reframe, C clear"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
