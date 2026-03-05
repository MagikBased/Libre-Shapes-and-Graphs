class_name LsgRuledSurface3D
extends MeshInstance3D

var mode_name: StringName = &"twist"
var u_steps: int = 120
var v_steps: int = 18
var width: float = 1.0
var length_scale: float = 2.4
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.88)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var us: int = maxi(4, u_steps)
	var vs: int = maxi(2, v_steps)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for iu in range(us - 1):
		var u0: float = float(iu) / float(us - 1)
		var u1: float = float(iu + 1) / float(us - 1)
		for iv in range(vs - 1):
			var v0: float = float(iv) / float(vs - 1)
			var v1: float = float(iv + 1) / float(vs - 1)

			var p00: Vector3 = _sample(u0, v0)
			var p10: Vector3 = _sample(u1, v0)
			var p01: Vector3 = _sample(u0, v1)
			var p11: Vector3 = _sample(u1, v1)

			_add_tri(st, p00, p10, p11)
			_add_tri(st, p00, p11, p01)

	st.generate_normals()
	mesh = st.commit()


func _sample(u: float, v: float) -> Vector3:
	var a: Vector3 = _boundary_a(u)
	var b: Vector3 = _boundary_b(u)
	return a.lerp(b, v)


func _boundary_a(u: float) -> Vector3:
	var t: float = lerpf(-PI, PI, u)
	var ls: float = maxf(0.05, length_scale)
	var p: float = phase
	var m: String = String(mode_name).to_lower()

	if m == "braid":
		return Vector3(
			ls * 0.95 * sin(t + p),
			0.95 * cos(2.0 * t + p * 1.2),
			ls * 0.6 * cos(t)
		)
	if m == "saddle":
		var x: float = lerpf(-ls, ls, u)
		return Vector3(x, 0.55 * x * x - 0.7 + 0.22 * sin(p + t), -width)
	return Vector3(
		ls * sin(t),
		0.65 * cos(t + p * 0.8),
		-width + 0.18 * sin(2.0 * t + p)
	)


func _boundary_b(u: float) -> Vector3:
	var t: float = lerpf(-PI, PI, u)
	var ls: float = maxf(0.05, length_scale)
	var p: float = phase
	var m: String = String(mode_name).to_lower()

	if m == "braid":
		return Vector3(
			ls * 0.95 * sin(t + p + PI),
			-0.95 * cos(2.0 * t + p * 1.2),
			ls * 0.6 * cos(t + 0.5)
		)
	if m == "saddle":
		var x: float = lerpf(-ls, ls, u)
		return Vector3(x, -0.55 * x * x + 0.7 + 0.22 * cos(p + t), width)
	return Vector3(
		ls * sin(t + PI * 0.45),
		-0.65 * cos(t - p * 0.8),
		width + 0.18 * cos(2.0 * t - p)
	)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
