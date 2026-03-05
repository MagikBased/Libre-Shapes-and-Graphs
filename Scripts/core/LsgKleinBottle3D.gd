class_name LsgKleinBottle3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 110
var v_steps: int = 56
var radius_scale: float = 0.22
var shape_scale: float = 1.0
var phase: float = 0.0
var surface_color: Color = Color(0.38, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var us: int = maxi(8, u_steps)
	var vs: int = maxi(8, v_steps)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for iu in range(us - 1):
		var uu0: float = float(iu) / float(us - 1)
		var uu1: float = float(iu + 1) / float(us - 1)
		for iv in range(vs - 1):
			var vv0: float = float(iv) / float(vs - 1)
			var vv1: float = float(iv + 1) / float(vs - 1)

			var p00: Vector3 = _sample(uu0, vv0)
			var p10: Vector3 = _sample(uu1, vv0)
			var p01: Vector3 = _sample(uu0, vv1)
			var p11: Vector3 = _sample(uu1, vv1)

			_add_tri(st, p00, p10, p11)
			_add_tri(st, p00, p11, p01)

	st.generate_normals()
	mesh = st.commit()


func _sample(uu: float, vv: float) -> Vector3:
	var u: float = TAU * uu
	var v: float = TAU * vv
	var p: float = phase
	var mode: String = String(mode_name).to_lower()
	var s: float = maxf(0.01, shape_scale)
	var r: float = maxf(0.01, radius_scale)

	if mode == "figure8":
		var x0: float = (2.0 + cos(u * 0.5 + p * 0.18) * sin(v) - sin(u * 0.5 + p * 0.18) * sin(2.0 * v)) * cos(u)
		var y0: float = (2.0 + cos(u * 0.5 + p * 0.18) * sin(v) - sin(u * 0.5 + p * 0.18) * sin(2.0 * v)) * sin(u)
		var z0: float = sin(u * 0.5 + p * 0.18) * sin(v) + cos(u * 0.5 + p * 0.18) * sin(2.0 * v)
		return Vector3(x0, z0, y0) * (r * 3.4 * s)

	if mode == "pinched":
		var pinch: float = 0.45 + 0.28 * sin(v + p * 0.4)
		var x1: float = (2.0 + pinch * cos(u * 0.5) * sin(v) - pinch * sin(u * 0.5) * sin(2.0 * v)) * cos(u)
		var y1: float = (2.0 + pinch * cos(u * 0.5) * sin(v) - pinch * sin(u * 0.5) * sin(2.0 * v)) * sin(u)
		var z1: float = pinch * sin(u * 0.5) * sin(v) + pinch * cos(u * 0.5) * sin(2.0 * v)
		return Vector3(x1, z1, y1) * (r * 3.4 * s)

	var x: float = (2.0 + cos(u * 0.5 + p * 0.2) * sin(v) - sin(u * 0.5 + p * 0.2) * sin(2.0 * v)) * cos(u)
	var y: float = (2.0 + cos(u * 0.5 + p * 0.2) * sin(v) - sin(u * 0.5 + p * 0.2) * sin(2.0 * v)) * sin(u)
	var z: float = sin(u * 0.5 + p * 0.2) * sin(v) + cos(u * 0.5 + p * 0.2) * sin(2.0 * v)
	return Vector3(x, z, y) * (r * 3.4 * s)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
