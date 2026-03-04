# Demo: ThreeDSphericalHarmonicParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var harmonic: PortSphericalHarmonic3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"y32", &"y43", &"y54", &"mix"]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.34, -0.22, 11.5)
	set_camera_fov(68.0)

	axes = PortAxes3D.new()
	axes.axis_length = 4.0
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	harmonic = PortSphericalHarmonic3D.new()
	harmonic.harmonic_name = modes[mode_index]
	harmonic.theta_steps = 72
	harmonic.phi_steps = 40
	harmonic.base_radius = 1.35
	harmonic.amplitude = 0.55
	harmonic.surface_color = Color(0.36, 0.9, 1.0, 0.9)
	add_child(harmonic)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = harmonic.surface_color
	mat.roughness = 0.34
	mat.metallic = 0.1
	harmonic.material_override = mat

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.18) * 0.08
	harmonic.phase = time_accum
	if (int(floor(time_accum * 0.5)) % 2) == 0:
		harmonic.rebuild()


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
	harmonic.harmonic_name = modes[mode_index]
	harmonic.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, harmonic]
	tween_frame_to_nodes(nodes, 1.15, 0.84)
	tween_fov_to(68.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D spherical-harmonic parity: PortSphericalHarmonic3D | Space/1/2/3/4 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
