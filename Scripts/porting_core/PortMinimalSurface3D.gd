class_name PortMinimalSurface3D
extends MeshInstance3D

var mode_name: StringName = &"enneper"
var u_steps: int = 92
var v_steps: int = 92
var domain_radius: float = 1.25
var scale_factor: float = 0.95
var phase: float = 0.0
var surface_color: Color = Color(0.38, 0.9, 1.0, 0.88)


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
	var r: float = maxf(0.05, domain_radius)
	var s: float = maxf(0.01, scale_factor)
	var p: float = phase
	var mode: String = String(mode_name).to_lower()

	var u: float = lerpf(-r, r, uu)
	var v: float = lerpf(-r, r, vv)

	if mode == "helicoid":
		var angle: float = u * 1.7 + p * 0.25
		var radius_v: float = v
		return Vector3(
			radius_v * cos(angle),
			0.55 * u,
			radius_v * sin(angle)
		) * (1.2 * s)

	if mode == "catenoid":
		var u2: float = lerpf(-1.4, 1.4, uu)
		var v2: float = lerpf(-PI, PI, vv)
		var a: float = 0.75 + 0.08 * sin(p * 0.6)
		var ch: float = cosh(u2 / maxf(0.05, a))
		return Vector3(
			a * ch * cos(v2),
			u2,
			a * ch * sin(v2)
		) * (0.85 * s)

	# Enneper surface default.
	var x: float = u - (pow(u, 3.0) / 3.0) + u * v * v
	var z: float = v - (pow(v, 3.0) / 3.0) + v * u * u
	var y: float = (u * u - v * v) + 0.2 * sin((u + v) * 2.1 + p)
	return Vector3(x, y, z) * (0.62 * s)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
