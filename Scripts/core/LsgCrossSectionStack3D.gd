class_name LsgCrossSectionStack3D
extends MeshInstance3D

var stack_name: StringName = &"sphere_stack"
var slice_count: int = 18
var points_per_slice: int = 96
var y_min: float = -2.0
var y_max: float = 2.0
var base_radius: float = 1.7
var vertical_scale: float = 1.0
var phase: float = 0.0
var line_color: Color = Color(0.36, 0.9, 1.0, 0.84)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var slices: int = maxi(2, slice_count)
	var points: int = maxi(8, points_per_slice)
	var mesh_data := ImmediateMesh.new()
	mesh_data.clear_surfaces()
	mesh_data.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh_data.surface_set_color(line_color)

	for si in range(slices):
		var sy: float = float(si) / float(slices - 1)
		var y: float = lerpf(y_min, y_max, sy)
		var ring: PackedVector3Array = _build_ring(y, points)
		if ring.size() < 2:
			continue
		for i in range(ring.size()):
			var a: Vector3 = ring[i]
			var b: Vector3 = ring[(i + 1) % ring.size()]
			mesh_data.surface_add_vertex(a)
			mesh_data.surface_add_vertex(b)

	mesh_data.surface_end()
	mesh = mesh_data


func _build_ring(y: float, points: int) -> PackedVector3Array:
	var out := PackedVector3Array()
	var stack_mode: String = String(stack_name).to_lower()
	var t_y: float = inverse_lerp(y_min, y_max, y)
	var yn: float = lerpf(-1.0, 1.0, t_y) * vertical_scale

	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		var r: float = _radius_for(stack_mode, yn, a)
		if r <= 0.0001:
			continue
		var twist: float = _twist_for(stack_mode, yn)
		var theta: float = a + twist
		var x: float = cos(theta) * r
		var z: float = sin(theta) * r
		out.append(Vector3(x, y, z))
	return out


func _radius_for(stack_mode: String, yn: float, a: float) -> float:
	if stack_mode == "sphere_stack":
		return maxf(0.0, sqrt(maxf(0.0, base_radius * base_radius - yn * yn * base_radius * base_radius)))
	if stack_mode == "ripple_stack":
		var sphere_r: float = maxf(0.0, sqrt(maxf(0.0, base_radius * base_radius - yn * yn * base_radius * base_radius)))
		return sphere_r * (0.75 + 0.25 * sin(4.0 * a + phase + yn * 3.0))
	if stack_mode == "flower_stack":
		var layer: float = 1.0 - 0.35 * absf(yn)
		return maxf(0.01, base_radius * layer * (0.62 + 0.38 * sin(6.0 * a + phase * 0.9 + yn * 2.5)))
	return maxf(0.0, sqrt(maxf(0.0, base_radius * base_radius - yn * yn * base_radius * base_radius)))


func _twist_for(stack_mode: String, yn: float) -> float:
	if stack_mode == "ripple_stack":
		return phase * 0.2 + yn * 0.9
	if stack_mode == "flower_stack":
		return phase * 0.4 + yn * 1.6
	return 0.0
