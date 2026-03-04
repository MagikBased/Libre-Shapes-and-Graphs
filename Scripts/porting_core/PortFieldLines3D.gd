class_name PortFieldLines3D
extends MeshInstance3D

var field_name: StringName = &"swirl"
var seed_bounds: AABB = AABB(Vector3(-2.0, -2.0, -2.0), Vector3(4.0, 4.0, 4.0))
var seed_step: float = 1.0
var line_steps: int = 40
var step_size: float = 0.16
var strength: float = 1.0
var line_color: Color = Color(0.38, 0.9, 1.0, 0.78)
var min_speed: float = 0.0001


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var immediate := ImmediateMesh.new()
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_set_color(line_color)

	var seeds: Array[Vector3] = _build_seeds()
	for seed_point in seeds:
		var points: PackedVector3Array = _integrate_streamline(seed_point, 1.0)
		_add_polyline(immediate, points)
		var backward: PackedVector3Array = _integrate_streamline(seed_point, -1.0)
		_add_polyline(immediate, backward)

	immediate.surface_end()
	mesh = immediate


func _build_seeds() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var step: float = maxf(0.2, absf(seed_step))
	var min_x: float = seed_bounds.position.x
	var min_y: float = seed_bounds.position.y
	var min_z: float = seed_bounds.position.z
	var max_x: float = seed_bounds.position.x + seed_bounds.size.x
	var max_y: float = seed_bounds.position.y + seed_bounds.size.y
	var max_z: float = seed_bounds.position.z + seed_bounds.size.z

	var x: float = min_x
	while x <= max_x + 0.0001:
		var y: float = min_y
		while y <= max_y + 0.0001:
			var z: float = min_z
			while z <= max_z + 0.0001:
				out.append(Vector3(x, y, z))
				z += step
			y += step
		x += step
	return out


func _integrate_streamline(start_point: Vector3, direction: float) -> PackedVector3Array:
	var out := PackedVector3Array()
	var p: Vector3 = start_point
	out.append(p)

	var count: int = maxi(2, line_steps)
	var h: float = maxf(0.001, absf(step_size)) * signf(direction)
	for _i in range(count):
		var v: Vector3 = _field_at(p) * strength
		var speed: float = v.length()
		if speed <= min_speed:
			break
		p += v.normalized() * h
		out.append(p)
	return out


func _add_polyline(immediate: ImmediateMesh, points: PackedVector3Array) -> void:
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		immediate.surface_add_vertex(points[i])
		immediate.surface_add_vertex(points[i + 1])


func _field_at(p: Vector3) -> Vector3:
	var mode: String = String(field_name).to_lower()
	if mode == "swirl":
		return Vector3(-p.z, 0.35 * sin(p.x * 0.9), p.x)
	if mode == "sink":
		return -p + Vector3(0.0, 0.35 * sin(p.x + p.z), 0.0)
	if mode == "helix":
		return Vector3(-p.y, p.x, 0.45 + 0.2 * sin(p.z * 1.2))
	return Vector3(-p.z, 0.0, p.x)
