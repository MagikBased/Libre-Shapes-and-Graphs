class_name LsgDiniSurface3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 120
var v_steps: int = 56
var u_max: float = 11.5
var v_min: float = 0.2
var v_max: float = 2.9
var a: float = 1.0
var b: float = 0.26
var scale_factor: float = 0.68
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var us: int = maxi(8, u_steps)
	var vs: int = maxi(6, v_steps)
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
	var aa: float = maxf(0.05, a)
	var bb: float = maxf(0.01, b)
	var ss: float = maxf(0.01, scale_factor)
	var p: float = phase

	if mode == "tight":
		bb *= 0.7
	elif mode == "wide":
		bb *= 1.35

	var u: float = lerpf(0.0, u_max, uu) + p * 0.08
	var v: float = lerpf(v_min, v_max, vv)
	var sin_v: float = sin(v)
	var cos_v: float = cos(v)
	var log_term: float = log(maxf(0.0001, tan(v * 0.5)))

	var x: float = aa * cos(u) * sin_v
	var z: float = aa * sin(u) * sin_v
	var y: float = aa * (cos_v + log_term) + bb * u
	return Vector3(x, y, z) * ss


func _add_tri(st: SurfaceTool, a0: Vector3, b0: Vector3, c0: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a0)
	st.set_color(surface_color)
	st.add_vertex(b0)
	st.set_color(surface_color)
	st.add_vertex(c0)
