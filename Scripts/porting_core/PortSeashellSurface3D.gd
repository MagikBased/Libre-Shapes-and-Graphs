class_name PortSeashellSurface3D
extends MeshInstance3D

var mode_name: StringName = &"nautilus"
var u_steps: int = 96
var v_steps: int = 52
var growth: float = 0.18
var tube_radius: float = 0.36
var height_scale: float = 0.7
var phase: float = 0.0
var surface_color: Color = Color(0.96, 0.72, 0.4, 0.9)


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
	var u: float = lerpf(0.0, TAU * 2.8, uu)
	var v: float = lerpf(-PI, PI, vv)
	var g: float = maxf(0.02, growth)
	var tube_r: float = maxf(0.02, tube_radius)
	var hs: float = maxf(0.01, height_scale)
	var p: float = phase
	var mode: String = String(mode_name).to_lower()

	var spiral_r: float = exp(g * u) * 0.18
	var wobble: float = 1.0
	if mode == "spiky":
		wobble = 1.0 + 0.28 * sin(7.0 * v + p * 0.7)
	elif mode == "smooth":
		wobble = 1.0 + 0.08 * sin(2.0 * v + p * 0.4)
	else:
		wobble = 1.0 + 0.18 * sin(4.0 * v + p * 0.6)

	var shell_r: float = (spiral_r + tube_r * cos(v) * wobble)
	var x: float = shell_r * cos(u + p * 0.12)
	var z: float = shell_r * sin(u + p * 0.12)
	var y: float = hs * (spiral_r * 0.7 + tube_r * sin(v) * wobble) - 1.4
	return Vector3(x, y, z)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
