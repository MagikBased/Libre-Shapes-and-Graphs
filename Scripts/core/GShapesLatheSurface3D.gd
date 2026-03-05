class_name GShapesLatheSurface3D
extends MeshInstance3D

var profile_name: StringName = &"vase"
var profile_phase: float = 0.0
var radius_scale: float = 1.0
var height_scale: float = 3.2
var profile_steps: int = 42
var angle_segments: int = 56
var closed_ends: bool = false
var surface_color: Color = Color(0.34, 0.86, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var p_steps: int = maxi(6, profile_steps)
	var a_steps: int = maxi(8, angle_segments)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for pi in range(p_steps - 1):
		var pu0: float = float(pi) / float(p_steps - 1)
		var pu1: float = float(pi + 1) / float(p_steps - 1)
		var p0: Vector2 = _sample_profile(pu0)
		var p1: Vector2 = _sample_profile(pu1)

		for ai in range(a_steps):
			var au0: float = float(ai) / float(a_steps)
			var au1: float = float(ai + 1) / float(a_steps)
			var a0: float = au0 * TAU
			var a1: float = au1 * TAU

			var v00: Vector3 = _revolve_point(p0, a0)
			var v01: Vector3 = _revolve_point(p0, a1)
			var v10: Vector3 = _revolve_point(p1, a0)
			var v11: Vector3 = _revolve_point(p1, a1)

			_add_tri(st, v00, v10, v11)
			_add_tri(st, v00, v11, v01)

	if closed_ends:
		_add_caps(st, p_steps, a_steps)

	st.generate_normals()
	mesh = st.commit()


func _sample_profile(u: float) -> Vector2:
	var y: float = lerpf(-0.5, 0.5, u) * height_scale
	var mode: String = String(profile_name).to_lower()
	var r: float = radius_scale

	match mode:
		"vase":
			r *= 0.28 + 0.52 * pow(sin(PI * u), 1.6) + 0.09 * sin(4.0 * PI * u + profile_phase)
		"goblet":
			r *= 0.18 + 0.68 * pow(sin(PI * u), 2.0) + 0.12 * pow(absf(u - 0.5) * 2.0, 1.8)
		"bulb":
			r *= 0.2 + 0.78 * sin(PI * u) + 0.06 * sin(8.0 * PI * u + profile_phase)
		_:
			r *= 0.28 + 0.52 * pow(sin(PI * u), 1.6) + 0.09 * sin(4.0 * PI * u + profile_phase)

	r = maxf(0.02, r)
	return Vector2(r, y)


func _revolve_point(profile: Vector2, angle: float) -> Vector3:
	return Vector3(cos(angle) * profile.x, profile.y, sin(angle) * profile.x)


func _add_caps(st: SurfaceTool, _p_steps: int, a_steps: int) -> void:
	var bottom: Vector2 = _sample_profile(0.0)
	var top: Vector2 = _sample_profile(1.0)
	var bottom_center: Vector3 = Vector3(0.0, bottom.y, 0.0)
	var top_center: Vector3 = Vector3(0.0, top.y, 0.0)

	for ai in range(a_steps):
		var au0: float = float(ai) / float(a_steps)
		var au1: float = float(ai + 1) / float(a_steps)
		var a0: float = au0 * TAU
		var a1: float = au1 * TAU

		var b0: Vector3 = _revolve_point(bottom, a0)
		var b1: Vector3 = _revolve_point(bottom, a1)
		_add_tri(st, bottom_center, b1, b0)

		var t0: Vector3 = _revolve_point(top, a0)
		var t1: Vector3 = _revolve_point(top, a1)
		_add_tri(st, top_center, t0, t1)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)



