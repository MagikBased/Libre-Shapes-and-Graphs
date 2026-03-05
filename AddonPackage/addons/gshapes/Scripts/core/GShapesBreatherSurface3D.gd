class_name GShapesBreatherSurface3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 96
var v_steps: int = 84
var u_min: float = -8.0
var u_max: float = 8.0
var v_min: float = -1.2
var v_max: float = 1.2
var a_param: float = 0.42
var scale_factor: float = 0.5
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
	var mode: String = String(mode_name).to_lower()
	var a: float = clampf(a_param, 0.05, 0.95)
	if mode == "tight":
		a = clampf(a * 0.75, 0.05, 0.95)
	elif mode == "soft":
		a = clampf(a * 1.2, 0.05, 0.95)

	var u: float = lerpf(u_min, u_max, uu) + phase * 0.16
	var v: float = lerpf(v_min, v_max, vv)
	var w: float = sqrt(maxf(0.0001, 1.0 - a * a))

	var denom: float = a * ((w * cosh(a * u)) * (w * cosh(a * u)) + a * a * sin(w * v) * sin(w * v))
	denom = maxf(0.0001, denom)

	var x: float = -u + (2.0 * (1.0 - a * a) * cosh(a * u) * sinh(a * u)) / denom
	var y: float = (2.0 * w * cosh(a * u) * (-(w * cos(v) * cos(w * v)) - sin(v) * sin(w * v))) / denom
	var z: float = (2.0 * w * cosh(a * u) * (-(w * sin(v) * cos(w * v)) + cos(v) * sin(w * v))) / denom

	return Vector3(x, y, z) * maxf(0.01, scale_factor)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)



