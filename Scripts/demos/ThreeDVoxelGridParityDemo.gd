# Demo: ThreeDVoxelGridParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var voxels: LsgVoxelGrid3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"sphere", &"torus", &"waves", &"blob"]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.36, -0.23, 12.1)
	set_camera_fov(69.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.9
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	voxels = GShapes.VoxelGrid3D.new()
	voxels.field_name = modes[mode_index]
	voxels.bounds = AABB(Vector3(-1.9, -1.9, -1.9), Vector3(3.8, 3.8, 3.8))
	voxels.x_steps = 18
	voxels.y_steps = 18
	voxels.z_steps = 18
	voxels.cube_scale = 0.17
	voxels.max_voxels = 15000
	voxels.voxel_color = Color(0.34, 0.9, 1.0, 0.84)
	add_child(voxels)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.2) * 0.08
	voxels.phase = time_accum
	voxels.iso_level = 0.0 + 0.18 * sin(time_accum * 0.95)
	if (int(floor(time_accum * 0.55)) % 2) == 0:
		voxels.rebuild()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_SPACE:
			_cycle_mode()
		elif key.keycode == KEY_1:
			_set_mode(0)
		elif key.keycode == KEY_2:
			_set_mode(1)
		elif key.keycode == KEY_3:
			_set_mode(2)
		elif key.keycode == KEY_4:
			_set_mode(3)
		elif key.keycode == KEY_F:
			_frame_all()


func _cycle_mode() -> void:
	if modes.is_empty():
		return
	mode_index = (mode_index + 1) % modes.size()
	_apply_mode()


func _set_mode(idx: int) -> void:
	if idx < 0 or idx >= modes.size():
		return
	mode_index = idx
	_apply_mode()


func _apply_mode() -> void:
	voxels.field_name = modes[mode_index]
	voxels.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, voxels]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(69.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D voxel-grid parity: LsgVoxelGrid3D | Space/1/2/3/4 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
