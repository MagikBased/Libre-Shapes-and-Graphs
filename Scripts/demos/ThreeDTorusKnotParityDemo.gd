# Demo: ThreeDTorusKnotParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var knot: LsgTorusKnot3D
var time_accum: float = 0.0
var mode_index: int = 0
var modes: Array[StringName] = [&"trefoil", &"cinquefoil", &"granny"]
var colors: Array[Color] = [
	Color(0.96, 0.7, 0.3, 0.9),
	Color(0.34, 0.88, 1.0, 0.88),
	Color(0.86, 0.54, 1.0, 0.9),
]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.38, -0.24, 13.0)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 4.1
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	knot = GShapes.TorusKnot3D.new()
	knot.mode_name = modes[mode_index]
	knot.major_radius = 1.95
	knot.minor_radius = 0.64
	knot.samples = 240
	knot.thickness = 0.05
	knot.turns = 1.0
	knot.path_color = colors[mode_index]
	add_child(knot)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.15) * 0.08
	knot.phase = time_accum
	if (int(floor(time_accum * 0.7)) % 2) == 0:
		knot.rebuild()


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
	knot.mode_name = modes[mode_index]
	knot.path_color = colors[mode_index]
	knot.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, knot]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(70.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D torus-knot parity: LsgTorusKnot3D | Space/1/2/3 mode, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
