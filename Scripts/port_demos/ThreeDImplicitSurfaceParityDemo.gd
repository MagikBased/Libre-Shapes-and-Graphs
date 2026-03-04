# Demo: ThreeDImplicitSurfaceParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var implicit_surface: PortImplicitSurface3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"sphere", &"torus", &"gyroid", &"heart"]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.37, -0.22, 11.8)
	set_camera_fov(68.0)

	axes = PortAxes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	implicit_surface = PortImplicitSurface3D.new()
	implicit_surface.surface_name = modes[mode_index]
	implicit_surface.x_steps = 30
	implicit_surface.y_steps = 30
	implicit_surface.z_steps = 30
	implicit_surface.iso_threshold = 0.09
	implicit_surface.max_points = 20000
	implicit_surface.point_scale = 0.034
	implicit_surface.point_color = Color(0.34, 0.9, 1.0, 0.88)
	add_child(implicit_surface)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.24) * 0.08
	implicit_surface.phase = time_accum
	if (int(floor(time_accum * 0.45)) % 2) == 0:
		implicit_surface.rebuild()


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
	implicit_surface.surface_name = modes[mode_index]
	implicit_surface.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, implicit_surface]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(68.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D implicit-surface parity: PortImplicitSurface3D | Space/1/2/3/4 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
