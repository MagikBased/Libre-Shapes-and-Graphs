# Demo: ThreeDExtrudedPolygonParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapes3DScene
var axes: GShapesAxes3D
var extruded: GShapesExtrudedPolygon3D
var marker: MeshInstance3D
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.33, -0.23, 10.6)
	set_camera_fov(66.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.6
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	extruded = GShapes.ExtrudedPolygon3D.new()
	extruded.surface_color = Color(0.32, 0.9, 1.0, 0.9)
	extruded.depth = 0.9
	extruded.set_polygon(_build_star_polygon(6, 1.45, 0.68))
	add_child(extruded)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = extruded.surface_color
	mat.roughness = 0.34
	mat.metallic = 0.06
	extruded.material_override = mat

	marker = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	marker.mesh = sphere
	var marker_mat := StandardMaterial3D.new()
	marker_mat.albedo_color = Color(1.0, 0.64, 0.28)
	marker_mat.emission_enabled = true
	marker_mat.emission = marker_mat.albedo_color * 0.22
	marker.material_override = marker_mat
	add_child(marker)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.3) * 0.08
	extruded.rotation.y += delta * 0.52
	extruded.rotation.x = sin(time_accum * 0.45) * 0.22
	extruded.depth = 0.62 + 0.5 * (0.5 + 0.5 * sin(time_accum * 1.1))
	extruded.set_polygon(_build_star_polygon(6, 1.45 + 0.08 * sin(time_accum * 0.9), 0.62 + 0.08 * cos(time_accum * 1.2)))

	var a: float = time_accum * 1.15
	marker.position = Vector3(cos(a) * 2.0, sin(time_accum * 1.6) * 0.85, sin(a) * 2.0)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			extruded.set_polygon(_build_star_polygon(5, 1.4, 0.62))
		elif key.keycode == KEY_2:
			extruded.set_polygon(_build_star_polygon(6, 1.45, 0.68))
		elif key.keycode == KEY_3:
			extruded.set_polygon(_build_star_polygon(8, 1.55, 0.7))
		elif key.keycode == KEY_F:
			_frame_all()


func _frame_all() -> void:
	var nodes: Array = [axes, extruded, marker]
	tween_frame_to_nodes(nodes, 1.1, 0.82)
	tween_fov_to(66.0, 0.82)


func _build_star_polygon(points: int, outer_radius: float, inner_radius: float) -> PackedVector2Array:
	var spikes: int = maxi(3, points)
	var out := PackedVector2Array()
	var total: int = spikes * 2
	for i in range(total):
		var t: float = TAU * float(i) / float(total)
		var radius: float = outer_radius if (i % 2) == 0 else inner_radius
		out.append(Vector2(cos(t) * radius, sin(t) * radius))
	return out


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D extruded-polygon parity: GShapesExtrudedPolygon3D | 1/2/3 shape, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)




