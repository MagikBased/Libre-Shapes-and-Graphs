class_name GShapesSphericalGrid3D
extends Node3D

var radius: float = 2.0
var latitude_count: int = 10
var longitude_count: int = 14
var angular_segments: int = 72

var major_latitude_step: int = 2
var major_longitude_step: int = 3

var major_color: Color = Color(0.84, 0.9, 1.0, 0.74)
var minor_color: Color = Color(0.55, 0.63, 0.76, 0.46)
var equator_color: Color = Color(1.0, 0.66, 0.32, 0.9)

var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_ensure_mesh_instance()
	rebuild()


func rebuild() -> void:
	_ensure_mesh_instance()
	var immediate := ImmediateMesh.new()
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)

	var r: float = maxf(0.01, absf(radius))
	var lat_count: int = maxi(2, latitude_count)
	var lon_count: int = maxi(3, longitude_count)
	var segs: int = maxi(12, angular_segments)

	for i in range(1, lat_count):
		var t_lat: float = float(i) / float(lat_count)
		var phi: float = -PI * 0.5 + PI * t_lat
		var y: float = sin(phi) * r
		var ring_r: float = cos(phi) * r
		if ring_r <= 0.0001:
			continue
		var is_equator: bool = absf(y) <= r * 0.03
		var is_major: bool = (i % maxi(1, major_latitude_step)) == 0
		var color: Color = equator_color if is_equator else (major_color if is_major else minor_color)
		_add_ring(immediate, y, ring_r, segs, color)

	for j in range(lon_count):
		var is_major_lon: bool = (j % maxi(1, major_longitude_step)) == 0
		var lon_color: Color = major_color if is_major_lon else minor_color
		_add_longitude(immediate, r, j, lon_count, segs, lon_color)

	immediate.surface_end()
	_mesh_instance.mesh = immediate


func _ensure_mesh_instance() -> void:
	if _mesh_instance != null:
		return
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)


func _add_ring(mesh: ImmediateMesh, y: float, ring_radius: float, segs: int, color: Color) -> void:
	for s in range(segs):
		var t0: float = TAU * float(s) / float(segs)
		var t1: float = TAU * float(s + 1) / float(segs)
		var a := Vector3(cos(t0) * ring_radius, y, sin(t0) * ring_radius)
		var b := Vector3(cos(t1) * ring_radius, y, sin(t1) * ring_radius)
		_add_line(mesh, a, b, color)


func _add_longitude(mesh: ImmediateMesh, r: float, idx: int, total: int, segs: int, color: Color) -> void:
	var theta: float = TAU * float(idx) / float(total)
	for s in range(segs):
		var v0: float = float(s) / float(segs)
		var v1: float = float(s + 1) / float(segs)
		var phi0: float = -PI * 0.5 + PI * v0
		var phi1: float = -PI * 0.5 + PI * v1
		var a := Vector3(cos(theta) * cos(phi0) * r, sin(phi0) * r, sin(theta) * cos(phi0) * r)
		var b := Vector3(cos(theta) * cos(phi1) * r, sin(phi1) * r, sin(theta) * cos(phi1) * r)
		_add_line(mesh, a, b, color)


func _add_line(mesh: ImmediateMesh, a: Vector3, b: Vector3, color: Color) -> void:
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(a)
	mesh.surface_add_vertex(b)



