class_name GShapesExtrudedPolygon3D
extends MeshInstance3D

var polygon_points: PackedVector2Array = PackedVector2Array()
var depth: float = 0.7
var centered: bool = true
var cap_top: bool = true
var cap_bottom: bool = true
var surface_color: Color = Color(0.34, 0.88, 1.0, 0.9)


func _ready() -> void:
	if polygon_points.is_empty():
		polygon_points = _default_polygon()
	rebuild()


func set_polygon(points: PackedVector2Array) -> void:
	polygon_points = points
	rebuild()


func rebuild() -> void:
	var points: PackedVector2Array = polygon_points
	if points.size() < 3:
		mesh = null
		return

	var tris: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	if tris.is_empty():
		mesh = null
		return

	var half_depth: float = absf(depth) * 0.5
	var z_top: float = half_depth if centered else absf(depth)
	var z_bottom: float = -half_depth if centered else 0.0

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	if cap_top:
		for i in range(0, tris.size(), 3):
			var a: Vector2 = points[tris[i]]
			var b: Vector2 = points[tris[i + 1]]
			var c: Vector2 = points[tris[i + 2]]
			_add_tri(st, Vector3(a.x, a.y, z_top), Vector3(b.x, b.y, z_top), Vector3(c.x, c.y, z_top))

	if cap_bottom:
		for i in range(0, tris.size(), 3):
			var a: Vector2 = points[tris[i]]
			var b: Vector2 = points[tris[i + 1]]
			var c: Vector2 = points[tris[i + 2]]
			_add_tri(st, Vector3(c.x, c.y, z_bottom), Vector3(b.x, b.y, z_bottom), Vector3(a.x, a.y, z_bottom))

	var count: int = points.size()
	for i in range(count):
		var j: int = (i + 1) % count
		var p0: Vector2 = points[i]
		var p1: Vector2 = points[j]

		var a0 := Vector3(p0.x, p0.y, z_bottom)
		var a1 := Vector3(p1.x, p1.y, z_bottom)
		var b0 := Vector3(p0.x, p0.y, z_top)
		var b1 := Vector3(p1.x, p1.y, z_top)

		_add_tri(st, a0, a1, b1)
		_add_tri(st, a0, b1, b0)

	st.generate_normals()
	mesh = st.commit()


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)


func _default_polygon() -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.append(Vector2(-1.0, -0.8))
	pts.append(Vector2(1.0, -0.8))
	pts.append(Vector2(1.2, 0.3))
	pts.append(Vector2(0.1, 1.1))
	pts.append(Vector2(-1.1, 0.4))
	return pts



