# Demo: ThreeDSuperShapeParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var super_shape: LsgSuperShape3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"star", &"flower", &"boxy"]
var colors: Array[Color] = [
	Color(0.36, 0.9, 1.0, 0.9),
	Color(1.0, 0.64, 0.3, 0.9),
	Color(0.8, 0.56, 1.0, 0.9),
]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.35, -0.23, 11.8)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 4.0
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	super_shape = GShapes.SuperShape3D.new()
	super_shape.mode_name = modes[mode_index]
	super_shape.lon_steps = 96
	super_shape.lat_steps = 52
	super_shape.radius_scale = 1.6
	super_shape.thickness_scale = 1.0
	super_shape.surface_color = colors[mode_index]
	add_child(super_shape)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.18) * 0.08
	super_shape.phase = time_accum
	super_shape.rotation.y += delta * 0.38
	if (int(floor(time_accum * 0.62)) % 2) == 0:
		super_shape.rebuild()


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
	super_shape.mode_name = modes[mode_index]
	super_shape.surface_color = colors[mode_index]
	super_shape.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, super_shape]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(70.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D super-shape parity: LsgSuperShape3D | Space/1/2/3 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
