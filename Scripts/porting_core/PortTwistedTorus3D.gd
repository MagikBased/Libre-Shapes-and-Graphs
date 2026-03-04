class_name PortTwistedTorus3D
extends MeshInstance3D

var mode_name: StringName = &"standard"
var u_steps: int = 96
var v_steps: int = 52
var major_radius: float = 1.8
var minor_radius: float = 0.46
var twist_strength: float = 1.0
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.9)


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
	var u: float = lerpf(0.0, TAU, uu)
	var v: float = lerpf(0.0, TAU, vv)
	var p: float = phase
	var major: float = maxf(0.05, major_radius)
	var minor: float = maxf(0.01, minor_radius)
	var twist: float = maxf(0.0, twist_strength)
	var mode: String = String(mode_name).to_lower()

	var twist_mul: float = 1.0
	if mode == "braided":
		twist_mul = 2.0
	elif mode == "wavy":
		twist_mul = 1.0 + 0.35 * sin(3.0 * u + p * 0.6)

	var v_twisted: float = v + twist * twist_mul * u + p * 0.35
	var ring_r: float = major
	if mode == "wavy":
		ring_r += 0.14 * sin(5.0 * u + p * 0.7)

	var x: float = (ring_r + minor * cos(v_twisted)) * cos(u)
	var y: float = minor * sin(v_twisted)
	var z: float = (ring_r + minor * cos(v_twisted)) * sin(u)
	return Vector3(x, y, z)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
