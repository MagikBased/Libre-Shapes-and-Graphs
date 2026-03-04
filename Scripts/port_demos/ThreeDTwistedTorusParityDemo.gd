# Demo: ThreeDTwistedTorusParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var torus: PortTwistedTorus3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"standard", &"braided", &"wavy"]
var colors: Array[Color] = [
	Color(0.36, 0.9, 1.0, 0.9),
	Color(1.0, 0.66, 0.32, 0.9),
	Color(0.84, 0.58, 1.0, 0.9),
]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.34, -0.22, 10.9)
	set_camera_fov(70.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.9
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	torus = PortTwistedTorus3D.new()
	torus.mode_name = modes[mode_index]
	torus.u_steps = 100
	torus.v_steps = 56
	torus.major_radius = 1.75
	torus.minor_radius = 0.44
	torus.twist_strength = 1.0
	torus.surface_color = colors[mode_index]
	add_child(torus)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.16) * 0.08
	torus.phase = time_accum
	torus.rotation.y += delta * 0.31
	if (int(floor(time_accum * 0.6)) % 2) == 0:
		torus.rebuild()


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
	torus.mode_name = modes[mode_index]
	torus.surface_color = colors[mode_index]
	torus.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, torus]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(70.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D twisted-torus parity: PortTwistedTorus3D | Space/1/2/3 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
