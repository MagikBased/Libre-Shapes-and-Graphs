class_name LsgTubePath3D
extends MeshInstance3D

var path_points: Array[Vector3] = []
var radius: float = 0.08
var radial_segments: int = 10
var path_color: Color = Color(0.46, 0.88, 1.0, 0.9)
var smooth_shading: bool = true
var closed_path: bool = false


func set_points(points: Array[Vector3]) -> void:
	path_points = points.duplicate()
	rebuild()


func clear_points() -> void:
	path_points.clear()
	mesh = null


func rebuild() -> void:
	var count: int = path_points.size()
	if count < 2:
		mesh = null
		return

	var rings: int = count if closed_path else count
	var seg_count: int = maxi(3, radial_segments)
	var r: float = maxf(0.001, radius)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(path_color)

	for i in range(rings):
		var next_i: int = i + 1
		if next_i >= count:
			if not closed_path:
				break
			next_i = 0

		var p0: Vector3 = path_points[i]
		var p1: Vector3 = path_points[next_i]
		var tangent0: Vector3 = _segment_tangent(i)
		var tangent1: Vector3 = _segment_tangent(next_i)

		var frame0: Basis = _frame_from_tangent(tangent0)
		var frame1: Basis = _frame_from_tangent(tangent1)

		for s in range(seg_count):
			var a0: float = TAU * float(s) / float(seg_count)
			var a1: float = TAU * float(s + 1) / float(seg_count)

			var n00: Vector3 = (frame0.x * cos(a0) + frame0.y * sin(a0)).normalized()
			var n01: Vector3 = (frame0.x * cos(a1) + frame0.y * sin(a1)).normalized()
			var n10: Vector3 = (frame1.x * cos(a0) + frame1.y * sin(a0)).normalized()
			var n11: Vector3 = (frame1.x * cos(a1) + frame1.y * sin(a1)).normalized()

			var v00: Vector3 = p0 + n00 * r
			var v01: Vector3 = p0 + n01 * r
			var v10: Vector3 = p1 + n10 * r
			var v11: Vector3 = p1 + n11 * r

			_add_tri(st, v00, n00, v10, n10, v11, n11)
			_add_tri(st, v00, n00, v11, n11, v01, n01)

	if smooth_shading:
		st.generate_normals()

	mesh = st.commit()


func _segment_tangent(index: int) -> Vector3:
	var count: int = path_points.size()
	if count < 2:
		return Vector3.FORWARD

	var prev_idx: int = index - 1
	var next_idx: int = index + 1
	if closed_path:
		prev_idx = (index - 1 + count) % count
		next_idx = (index + 1) % count
	else:
		prev_idx = maxi(0, prev_idx)
		next_idx = mini(count - 1, next_idx)

	var tangent: Vector3 = path_points[next_idx] - path_points[prev_idx]
	if tangent.length() <= 0.0001:
		tangent = Vector3.FORWARD
	return tangent.normalized()


func _frame_from_tangent(tangent: Vector3) -> Basis:
	var up_hint: Vector3 = Vector3.UP
	if absf(tangent.dot(up_hint)) > 0.98:
		up_hint = Vector3.RIGHT
	var right: Vector3 = tangent.cross(up_hint).normalized()
	var up: Vector3 = right.cross(tangent).normalized()
	return Basis(right, up, tangent)


func _add_tri(
		st: SurfaceTool,
		v0: Vector3, n0: Vector3,
		v1: Vector3, n1: Vector3,
		v2: Vector3, n2: Vector3
	) -> void:
	st.set_normal(n0)
	st.add_vertex(v0)
	st.set_normal(n1)
	st.add_vertex(v1)
	st.set_normal(n2)
	st.add_vertex(v2)
