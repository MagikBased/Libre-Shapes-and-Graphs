class_name PortHyperbolicParaboloid3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 96
var v_steps: int = 96
var x_min: float = -1.9
var x_max: float = 1.9
var y_min: float = -1.9
var y_max: float = 1.9
var scale_factor: float = 0.9
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
	var x: float = lerpf(x_min, x_max, uu)
	var y: float = lerpf(y_min, y_max, vv)
	var z: float = (x * x - y * y) * 0.36

	if mode == "tight":
		z *= 0.72
	elif mode == "wave":
		z += 0.34 * sin(2.1 * x + phase) * cos(2.1 * y + phase * 0.7)

	return Vector3(x, z, y) * maxf(0.01, scale_factor)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
