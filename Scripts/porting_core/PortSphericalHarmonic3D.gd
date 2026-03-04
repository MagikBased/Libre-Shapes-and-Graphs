class_name PortSphericalHarmonic3D
extends MeshInstance3D

var harmonic_name: StringName = &"y32"
var theta_steps: int = 72
var phi_steps: int = 38
var base_radius: float = 1.35
var amplitude: float = 0.55
var phase: float = 0.0
var surface_scale: float = 1.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var ts: int = maxi(6, theta_steps)
	var ps: int = maxi(4, phi_steps)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for it in range(ts):
		var t0: float = TAU * float(it) / float(ts)
		var t1: float = TAU * float(it + 1) / float(ts)
		for ip in range(ps - 1):
			var u0: float = float(ip) / float(ps - 1)
			var u1: float = float(ip + 1) / float(ps - 1)
			var p0: float = lerpf(0.001, PI - 0.001, u0)
			var p1: float = lerpf(0.001, PI - 0.001, u1)

			var a: Vector3 = _sample(t0, p0)
			var b: Vector3 = _sample(t1, p0)
			var c: Vector3 = _sample(t1, p1)
			var d: Vector3 = _sample(t0, p1)

			_add_tri(st, a, b, c)
			_add_tri(st, a, c, d)

	st.generate_normals()
	mesh = st.commit()


func _sample(theta: float, phi: float) -> Vector3:
	var r: float = base_radius + amplitude * _harmonic(theta, phi)
	r = maxf(0.08, r) * surface_scale
	var x: float = r * sin(phi) * cos(theta)
	var y: float = r * cos(phi)
	var z: float = r * sin(phi) * sin(theta)
	return Vector3(x, y, z)


func _harmonic(theta: float, phi: float) -> float:
	var p: float = phase
	var n: String = String(harmonic_name).to_lower()
	if n == "y32":
		return sin(3.0 * theta + p) * sin(phi) * sin(phi) * cos(phi)
	if n == "y43":
		return cos(4.0 * theta - p * 0.8) * pow(sin(phi), 3.0) * cos(phi)
	if n == "y54":
		return sin(5.0 * theta + p * 0.6) * pow(sin(phi), 4.0) * cos(phi)
	if n == "mix":
		return 0.6 * sin(3.0 * theta + p) * sin(phi) * sin(phi) * cos(phi) + 0.4 * cos(4.0 * theta - p * 0.7) * pow(sin(phi), 3.0) * cos(phi)
	return sin(3.0 * theta + p) * sin(phi) * sin(phi) * cos(phi)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
