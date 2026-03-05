class_name LsgWaveSphere3D
extends MeshInstance3D

var mode_name: StringName = &"radial"
var u_steps: int = 108
var v_steps: int = 54
var base_radius: float = 1.6
var wave_amplitude: float = 0.28
var wave_frequency: float = 5.0
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
	var theta: float = lerpf(0.0, TAU, uu)
	var phi: float = lerpf(0.0, PI, vv)
	var r0: float = maxf(0.05, base_radius)
	var amp: float = maxf(0.0, wave_amplitude)
	var freq: float = maxf(0.1, wave_frequency)
	var p: float = phase
	var mode: String = String(mode_name).to_lower()

	var wave: float = 0.0
	if mode == "lat_lon":
		wave = sin(freq * theta + p) * cos(freq * phi - p * 0.8)
	elif mode == "spikes":
		wave = absf(sin(freq * theta + p)) * absf(cos((freq + 2.0) * phi - p * 0.6))
	else:
		wave = sin(freq * theta + p) * sin((freq - 1.0) * phi + p * 0.7)

	var r: float = r0 + amp * wave
	var x: float = r * sin(phi) * cos(theta)
	var y: float = r * cos(phi)
	var z: float = r * sin(phi) * sin(theta)
	return Vector3(x, y, z)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)
