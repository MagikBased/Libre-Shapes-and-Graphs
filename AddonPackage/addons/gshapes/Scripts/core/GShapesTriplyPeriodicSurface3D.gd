class_name GShapesTriplyPeriodicSurface3D
extends MeshInstance3D

var mode_name: StringName = &"gyroid"
var u_steps: int = 96
var v_steps: int = 96
var domain_scale: float = 2.3
var height_scale: float = 0.8
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
	var s: float = maxf(0.1, domain_scale)
	var h: float = maxf(0.05, height_scale)
	var p: float = phase
	var mode: String = String(mode_name).to_lower()

	var x: float = lerpf(-s, s, uu)
	var z: float = lerpf(-s, s, vv)
	var y: float = 0.0

	if mode == "schwarz_p":
		y = h * (cos(x + p * 0.3) + cos(z - p * 0.2))
	elif mode == "schwarz_d":
		y = h * (
			sin(x + p * 0.3) * sin(z - p * 0.2) +
			sin(0.75 * x - p * 0.25) * cos(0.75 * z + p * 0.18)
		)
	else:
		y = h * (
			sin(x + p * 0.35) * cos(z) +
			sin(z - p * 0.22) * cos(x)
		)

	return Vector3(x, y, z)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)



