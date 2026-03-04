class_name PortCrossCapSurface3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 104
var v_steps: int = 78
var u_min: float = 0.0
var u_max: float = TAU
var v_min: float = 0.0
var v_max: float = TAU
var scale_factor: float = 1.2
var phase: float = 0.0
var surface_color: Color = Color(0.42, 0.9, 1.0, 0.88)


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
	var u: float = lerpf(u_min, u_max, uu)
	var v: float = lerpf(v_min, v_max, vv)
	var ripple: float = 0.0
	var pinch: float = 1.0

	if mode == "tight":
		pinch = 0.78
	elif mode == "wave":
		ripple = 0.22 * sin(3.0 * u + phase * 1.2) * cos(2.0 * v)

	var su: float = sin(u)
	var cu: float = cos(u)
	var s2u: float = sin(2.0 * u)
	var sv: float = sin(v)
	var cv: float = cos(v)

	var x: float = su * s2u * pinch
	var y: float = su * su * cv
	var z: float = cu * sv

	x *= 1.0 + ripple
	y *= 1.0 + ripple * 0.6
	z *= 1.0 + ripple

	return Vector3(x, y, z) * maxf(0.01, scale_factor)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
