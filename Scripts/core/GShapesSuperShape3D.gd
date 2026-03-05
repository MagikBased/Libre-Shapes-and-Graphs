class_name GShapesSuperShape3D
extends MeshInstance3D

var mode_name: StringName = &"star"
var lon_steps: int = 96
var lat_steps: int = 48
var radius_scale: float = 1.55
var thickness_scale: float = 0.95
var phase: float = 0.0
var surface_color: Color = Color(0.36, 0.9, 1.0, 0.9)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var u_steps: int = maxi(8, lon_steps)
	var v_steps: int = maxi(6, lat_steps)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for iu in range(u_steps - 1):
		var uu0: float = float(iu) / float(u_steps - 1)
		var uu1: float = float(iu + 1) / float(u_steps - 1)
		for iv in range(v_steps - 1):
			var vv0: float = float(iv) / float(v_steps - 1)
			var vv1: float = float(iv + 1) / float(v_steps - 1)

			var p00: Vector3 = _sample(uu0, vv0)
			var p10: Vector3 = _sample(uu1, vv0)
			var p01: Vector3 = _sample(uu0, vv1)
			var p11: Vector3 = _sample(uu1, vv1)

			_add_tri(st, p00, p10, p11)
			_add_tri(st, p00, p11, p01)

	st.generate_normals()
	mesh = st.commit()


func _sample(uu: float, vv: float) -> Vector3:
	var theta: float = lerpf(-PI, PI, uu)
	var phi: float = lerpf(-PI * 0.5, PI * 0.5, vv)
	var p: float = phase
	var rs: float = maxf(0.01, radius_scale)
	var ts: float = maxf(0.01, thickness_scale)

	var params: Dictionary = _shape_params(String(mode_name).to_lower())
	var r1: float = _superformula(theta, params["m1"], params["a1"], params["b1"], params["n11"], params["n12"], params["n13"])
	var r2: float = _superformula(phi, params["m2"], params["a2"], params["b2"], params["n21"], params["n22"], params["n23"])

	var x: float = rs * r1 * cos(theta + p * 0.25) * r2 * cos(phi)
	var y: float = ts * r2 * sin(phi)
	var z: float = rs * r1 * sin(theta + p * 0.25) * r2 * cos(phi)
	return Vector3(x, y, z)


func _shape_params(mode: String) -> Dictionary:
	if mode == "flower":
		return {
			"m1": 7.0, "a1": 1.0, "b1": 1.0, "n11": 0.28, "n12": 1.55 + 0.25 * sin(phase * 0.8), "n13": 1.55,
			"m2": 5.0, "a2": 1.0, "b2": 1.0, "n21": 0.35, "n22": 1.35, "n23": 1.35 + 0.2 * cos(phase * 0.7),
		}
	if mode == "boxy":
		return {
			"m1": 4.0, "a1": 1.0, "b1": 1.0, "n11": 0.2, "n12": 0.2, "n13": 0.2,
			"m2": 4.0, "a2": 1.0, "b2": 1.0, "n21": 0.2, "n22": 0.2, "n23": 0.2,
		}
	return {
		"m1": 6.0 + 0.35 * sin(phase * 0.6), "a1": 1.0, "b1": 1.0, "n11": 0.22, "n12": 1.7, "n13": 1.7,
		"m2": 6.0, "a2": 1.0, "b2": 1.0, "n21": 0.3, "n22": 1.25, "n23": 1.25,
	}


func _superformula(angle: float, m: float, a: float, b: float, n1: float, n2: float, n3: float) -> float:
	var t1: float = pow(absf(cos(m * angle * 0.25) / maxf(0.0001, a)), n2)
	var t2: float = pow(absf(sin(m * angle * 0.25) / maxf(0.0001, b)), n3)
	var q: float = pow(t1 + t2, 1.0 / maxf(0.0001, n1))
	return 1.0 / maxf(0.0001, q)


func _add_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(surface_color)
	st.add_vertex(a)
	st.set_color(surface_color)
	st.add_vertex(b)
	st.set_color(surface_color)
	st.add_vertex(c)



