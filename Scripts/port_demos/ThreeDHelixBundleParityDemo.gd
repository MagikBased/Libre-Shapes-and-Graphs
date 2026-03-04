# Demo: ThreeDHelixBundleParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var helix_bundle: PortHelixBundle3D
var time_accum: float = 0.0
var mode_index: int = 0
var count_index: int = 1
var modes: Array[StringName] = [&"uniform", &"alternating", &"braid"]
var strand_counts: Array[int] = [5, 8, 11]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.34, -0.2, 13.3)
	set_camera_fov(70.0)

	axes = PortAxes3D.new()
	axes.axis_length = 4.3
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	helix_bundle = PortHelixBundle3D.new()
	helix_bundle.mode_name = modes[mode_index]
	helix_bundle.helix_count = strand_counts[count_index]
	helix_bundle.turns = 3.8
	helix_bundle.bundle_radius = 1.7
	helix_bundle.vertical_span = 4.7
	helix_bundle.strand_wave = 0.2
	helix_bundle.thickness = 0.036
	add_child(helix_bundle)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.17) * 0.09
	helix_bundle.phase = time_accum * 0.95
	if (int(floor(time_accum * 0.6)) % 2) == 0:
		helix_bundle.rebuild()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_SPACE:
			_cycle_mode()
		elif key.keycode == KEY_1:
			_set_strand_count(0)
		elif key.keycode == KEY_2:
			_set_strand_count(1)
		elif key.keycode == KEY_3:
			_set_strand_count(2)
		elif key.keycode == KEY_F:
			_frame_all()


func _cycle_mode() -> void:
	if modes.is_empty():
		return
	mode_index = (mode_index + 1) % modes.size()
	_apply_config()


func _set_strand_count(idx: int) -> void:
	if idx < 0 or idx >= strand_counts.size():
		return
	count_index = idx
	_apply_config()


func _apply_config() -> void:
	helix_bundle.mode_name = modes[mode_index]
	helix_bundle.helix_count = strand_counts[count_index]
	helix_bundle.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, helix_bundle]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(70.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D helix-bundle parity: PortHelixBundle3D | Space mode, 1/2/3 strand count, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
