# Demo: ThreeDVectorFieldParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var vectors: Array[LsgVector3D] = []
var anchors: Array[Vector3] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.2, 0.0)
	set_orbit_pose(0.34, -0.28, 12.2)
	set_camera_fov(71.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_spawn_vector_grid()
	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.34) * 0.08
	for i in range(vectors.size()):
		var origin: Vector3 = anchors[i]
		var dir: Vector3 = _field_at(origin, time_accum)
		vectors[i].set_points(origin, origin + dir)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			_frame_all()


func _spawn_vector_grid() -> void:
	var coords: Array[float] = [-2.4, -1.2, 0.0, 1.2, 2.4]
	for x in coords:
		for z in coords:
			var anchor := Vector3(x, 0.0, z)
			var v: LsgVector3D = GShapes.Vector3D.new()
			v.shaft_radius = 0.035
			v.tip_radius = 0.085
			v.tip_length_ratio = 0.26
			v.vector_color = _color_for_anchor(anchor)
			add_child(v)
			v.set_points(anchor, anchor + _field_at(anchor, 0.0))
			vectors.append(v)
			anchors.append(anchor)


func _field_at(p: Vector3, t: float) -> Vector3:
	var swirl: Vector3 = Vector3(-p.z, 0.0, p.x) * 0.23
	var wave: Vector3 = Vector3(
		sin(p.z * 0.9 + t * 1.2),
		cos((p.x + p.z) * 0.7 + t * 1.6) * 0.9,
		cos(p.x * 0.85 - t * 1.15)
	) * 0.46
	return swirl + wave


func _color_for_anchor(p: Vector3) -> Color:
	var h: float = 0.07 + (p.x + 2.4) / 4.8 * 0.46
	var v: float = 0.88 + clampf((p.z + 2.4) / 4.8, 0.0, 1.0) * 0.08
	return Color.from_hsv(h, 0.72, v)


func _frame_all() -> void:
	var nodes: Array = [axes]
	for v in vectors:
		nodes.append(v)
	tween_frame_to_nodes(nodes, 1.2, 0.85)
	tween_fov_to(71.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D vector-field parity: animated LsgVector3D grid | RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
