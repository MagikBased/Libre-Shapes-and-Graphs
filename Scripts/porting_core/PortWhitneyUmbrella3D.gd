class_name PortWhitneyUmbrella3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 96
var v_steps: int = 72
var u_min: float = -1.5
var u_max: float = 1.5
var v_min: float = -1.5
var v_max: float = 1.5
var scale_factor: float = 1.35
var phase: float = 0.0
var surface_color: Color = Color(0.4, 0.9, 1.0, 0.88)


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
	var oscillation: float = sin(phase * 1.2 + 2.0 * u) * cos(phase * 0.9 + 2.0 * v)

	var x: float = u * v
	var y: float = u
	var z: float = v * v

	if mode == "twist":
		var ang: float = 0.5 * oscillation
		var cs: float = cos(ang)
		var sn: float = sin(ang)
		var xr: float = x * cs - y * sn
		var yr: float = x * sn + y * cs
		x = xr
		y = yr
	elif mode == "wave":
		z += 0.25 * oscillation

	return Vector3(x, z, y) * maxf(0.01, scale_factor)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
