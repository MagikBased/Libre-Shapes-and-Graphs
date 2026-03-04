class_name PortParametricSurface3D
extends MeshInstance3D

var surface_name: StringName = &"mobius"
var u_min: float = 0.0
var u_max: float = TAU
var v_min: float = -1.0
var v_max: float = 1.0
var u_steps: int = 80
var v_steps: int = 28
var surface_scale: float = 1.0
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var us: int = maxi(3, u_steps)
	var vs: int = maxi(3, v_steps)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for iu in range(us - 1):
		for iv in range(vs - 1):
			var uu0: float = float(iu) / float(us - 1)
			var vv0: float = float(iv) / float(vs - 1)
			var uu1: float = float(iu + 1) / float(us - 1)
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
	var u: float = lerpf(u_min, u_max, uu)
	var v: float = lerpf(v_min, v_max, vv)
	var p: float = phase
	var s: float = surface_scale
	var n: String = String(surface_name).to_lower()

	if n == "mobius":
		var x: float = (1.4 + 0.5 * v * cos(u * 0.5 + p * 0.35)) * cos(u)
		var y: float = (1.4 + 0.5 * v * cos(u * 0.5 + p * 0.35)) * sin(u)
		var z: float = 0.5 * v * sin(u * 0.5 + p * 0.35)
		return Vector3(x, z, y) * s
	if n == "torus":
		var r_major: float = 1.5 + 0.08 * sin(p * 0.8)
		var r_minor: float = 0.45 + 0.06 * cos(p * 1.1)
		var tx: float = (r_major + r_minor * cos(v + p * 0.5)) * cos(u)
		var ty: float = (r_major + r_minor * cos(v + p * 0.5)) * sin(u)
		var tz: float = r_minor * sin(v + p * 0.5)
		return Vector3(tx, tz, ty) * s
	if n == "wave_sheet":
		var wx: float = lerpf(-2.3, 2.3, uu)
		var wz: float = lerpf(-2.3, 2.3, vv)
		var wy: float = 0.52 * sin(wx * 1.4 + p) * cos(wz * 1.15 - p * 0.7)
		return Vector3(wx, wy, wz) * s

	var dx: float = (1.4 + 0.5 * v * cos(u * 0.5)) * cos(u)
	var dy: float = (1.4 + 0.5 * v * cos(u * 0.5)) * sin(u)
	var dz: float = 0.5 * v * sin(u * 0.5)
	return Vector3(dx, dz, dy) * s


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
