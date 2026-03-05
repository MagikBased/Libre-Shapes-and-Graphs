class_name LsgKuenSurface3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 110
var v_steps: int = 74
var u_min: float = -3.2
var u_max: float = 3.2
var v_min: float = -1.2
var v_max: float = 1.2
var scale_factor: float = 0.7
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.88)


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
	var u: float = lerpf(u_min, u_max, uu)
	var v: float = lerpf(v_min, v_max, vv)
	var p: float = phase
	var s: float = maxf(0.01, scale_factor)
	var mode: String = String(mode_name).to_lower()

	var v2: float = v
	if mode == "tight":
		v2 *= 0.7
	elif mode == "spread":
		v2 *= 1.25

	var denom: float = 1.0 + u * u + v2 * v2
	var x: float = 2.0 * (cosh(u) * cos(v2 + p * 0.1) + u * sinh(u)) / maxf(0.0001, denom)
	var y: float = 2.0 * (cosh(u) * sin(v2 + p * 0.1) - v2 * cos(v2)) / maxf(0.0001, denom)
	var z: float = log(maxf(0.0001, cosh(u))) + 0.25 * sin(v2 * 2.0 + p * 0.8)
	return Vector3(x, z, y) * (0.58 * s)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
