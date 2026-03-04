# Demo: ThreeDWaveSphereParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var wave_sphere: PortWaveSphere3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"radial", &"lat_lon", &"spikes"]
var colors: Array[Color] = [
	Color(0.36, 0.9, 1.0, 0.9),
	Color(1.0, 0.66, 0.32, 0.9),
	Color(0.84, 0.58, 1.0, 0.9),
]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.35, -0.22, 10.8)
	set_camera_fov(70.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	wave_sphere = PortWaveSphere3D.new()
	wave_sphere.mode_name = modes[mode_index]
	wave_sphere.u_steps = 110
	wave_sphere.v_steps = 58
	wave_sphere.base_radius = 1.55
	wave_sphere.wave_amplitude = 0.28
	wave_sphere.wave_frequency = 5.0
	wave_sphere.surface_color = colors[mode_index]
	add_child(wave_sphere)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.16) * 0.08
	wave_sphere.phase = time_accum
	wave_sphere.rotation.y += delta * 0.33
	if (int(floor(time_accum * 0.62)) % 2) == 0:
		wave_sphere.rebuild()


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
	wave_sphere.mode_name = modes[mode_index]
	wave_sphere.surface_color = colors[mode_index]
	wave_sphere.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, wave_sphere]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(70.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D wave-sphere parity: PortWaveSphere3D | Space/1/2/3 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
