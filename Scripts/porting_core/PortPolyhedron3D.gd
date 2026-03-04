class_name PortPolyhedron3D
extends MeshInstance3D

var polyhedron_name: StringName = &"tetra"
var radius: float = 1.2
var surface_color: Color = Color(0.34, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var data: Dictionary = _poly_data(String(polyhedron_name).to_lower())
	var vertices: Array[Vector3] = data.get("vertices", [])
	var faces: Array = data.get("faces", [])
	if vertices.is_empty() or faces.is_empty():
		mesh = null
		return

	var r: float = maxf(0.01, absf(radius))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for face_variant in faces:
		var face: Array = face_variant as Array
		if face.size() < 3:
			continue
		var ia: int = int(face[0])
		var ib: int = int(face[1])
		var ic: int = int(face[2])
		if ia < 0 or ib < 0 or ic < 0:
			continue
		if ia >= vertices.size() or ib >= vertices.size() or ic >= vertices.size():
			continue

		var a: Vector3 = vertices[ia].normalized() * r
		var b: Vector3 = vertices[ib].normalized() * r
		var c: Vector3 = vertices[ic].normalized() * r
		_add_tri(st, a, b, c)

	st.generate_normals()
	mesh = st.commit()


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)


func _poly_data(poly_mode: String) -> Dictionary:
	match poly_mode:
		"tetra":
			return _tetra_data()
		"octa":
			return _octa_data()
		"icosa":
			return _icosa_data()
		_:
			return _tetra_data()


func _tetra_data() -> Dictionary:
	var v: Array[Vector3] = [
		Vector3(1.0, 1.0, 1.0),
		Vector3(-1.0, -1.0, 1.0),
		Vector3(-1.0, 1.0, -1.0),
		Vector3(1.0, -1.0, -1.0),
	]
	var f: Array = [
		[0, 1, 2],
		[0, 3, 1],
		[0, 2, 3],
		[1, 3, 2],
	]
	return {"vertices": v, "faces": f}


func _octa_data() -> Dictionary:
	var v: Array[Vector3] = [
		Vector3(1.0, 0.0, 0.0),
		Vector3(-1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0.0),
		Vector3(0.0, -1.0, 0.0),
		Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, -1.0),
	]
	var f: Array = [
		[0, 2, 4],
		[4, 2, 1],
		[1, 2, 5],
		[5, 2, 0],
		[0, 4, 3],
		[4, 1, 3],
		[1, 5, 3],
		[5, 0, 3],
	]
	return {"vertices": v, "faces": f}


func _icosa_data() -> Dictionary:
	var phi: float = (1.0 + sqrt(5.0)) * 0.5
	var v: Array[Vector3] = [
		Vector3(-1.0, phi, 0.0),
		Vector3(1.0, phi, 0.0),
		Vector3(-1.0, -phi, 0.0),
		Vector3(1.0, -phi, 0.0),
		Vector3(0.0, -1.0, phi),
		Vector3(0.0, 1.0, phi),
		Vector3(0.0, -1.0, -phi),
		Vector3(0.0, 1.0, -phi),
		Vector3(phi, 0.0, -1.0),
		Vector3(phi, 0.0, 1.0),
		Vector3(-phi, 0.0, -1.0),
		Vector3(-phi, 0.0, 1.0),
	]
	var f: Array = [
		[0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
		[1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
		[3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
		[4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
	]
	return {"vertices": v, "faces": f}
