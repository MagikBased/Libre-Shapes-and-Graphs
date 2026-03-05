class_name GShapesMobiusStrip3D
extends MeshInstance3D

var mode_name: StringName = &"classic"
var u_steps: int = 120
var v_steps: int = 28
var strip_radius: float = 1.55
var strip_width: float = 0.52
var phase: float = 0.0
var surface_color: Color = Color(0.34, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var us: int = maxi(8, u_steps)
	var vs: int = maxi(4, v_steps)
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
	var v: float = lerpf(-1.0, 1.0, vv)
	var r: float = maxf(0.05, strip_radius)
	var w: float = maxf(0.01, strip_width)
	var p: float = phase
	var mode: String = String(mode_name).to_lower()

	var twist_mult: float = 0.5
	var ripple: float = 0.0
	if mode == "double_twist":
		twist_mult = 1.0
		ripple = 0.08 * sin(3.0 * u + p * 0.7)
	elif mode == "ripple":
		twist_mult = 0.5
		ripple = 0.14 * sin(5.0 * u + p * 0.9) * (0.5 + 0.5 * absf(v))

	var half_twist: float = twist_mult * u + p * 0.18
	var local_w: float = w + ripple

	var x: float = (r + v * local_w * cos(half_twist)) * cos(u)
	var z: float = (r + v * local_w * cos(half_twist)) * sin(u)
	var y: float = v * local_w * sin(half_twist)
	return Vector3(x, y, z)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)



