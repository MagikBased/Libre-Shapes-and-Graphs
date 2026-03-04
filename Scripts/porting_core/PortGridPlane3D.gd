class_name PortGridPlane3D
extends Node3D

var x_min: float = -4.0
var x_max: float = 4.0
var z_min: float = -4.0
var z_max: float = 4.0
var y_level: float = 0.0

var major_step: float = 1.0
var minor_step: float = 0.5

var major_color: Color = Color(0.58, 0.66, 0.8, 0.6)
var minor_color: Color = Color(0.34, 0.4, 0.52, 0.45)
var axis_color_x: Color = Color(1.0, 0.45, 0.38, 0.88)
var axis_color_z: Color = Color(0.45, 0.72, 1.0, 0.88)

var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_ensure_mesh_instance()
	rebuild()


func rebuild() -> void:
	_ensure_mesh_instance()
	var immediate := ImmediateMesh.new()
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)

	var min_x: float = minf(x_min, x_max)
	var max_x: float = maxf(x_min, x_max)
	var min_z: float = minf(z_min, z_max)
	var max_z: float = maxf(z_min, z_max)
	var minor: float = maxf(0.001, absf(minor_step))
	var major: float = maxf(minor, absf(major_step))

	var z: float = _first_step(min_z, minor)
	while z <= max_z + 0.0001:
		var is_major: bool = _is_major_line(z, major)
		var color: Color = major_color if is_major else minor_color
		if absf(z) <= minor * 0.5:
			color = axis_color_x
		_add_line(immediate, Vector3(min_x, y_level, z), Vector3(max_x, y_level, z), color)
		z += minor

	var x: float = _first_step(min_x, minor)
	while x <= max_x + 0.0001:
		var is_major: bool = _is_major_line(x, major)
		var color: Color = major_color if is_major else minor_color
		if absf(x) <= minor * 0.5:
			color = axis_color_z
		_add_line(immediate, Vector3(x, y_level, min_z), Vector3(x, y_level, max_z), color)
		x += minor

	immediate.surface_end()
	_mesh_instance.mesh = immediate


func _ensure_mesh_instance() -> void:
	if _mesh_instance != null:
		return
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)


func _add_line(mesh: ImmediateMesh, a: Vector3, b: Vector3, color: Color) -> void:
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(a)
	mesh.surface_add_vertex(b)


func _first_step(min_value: float, step: float) -> float:
	return floor(min_value / step) * step


func _is_major_line(value: float, step: float) -> bool:
	var k: float = value / step
	return absf(k - round(k)) <= 0.0001
