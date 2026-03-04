class_name PortSurfaceContours3D
extends MeshInstance3D

var surface_name: StringName = &"torus"
var u_lines: int = 18
var v_lines: int = 12
var samples_per_line: int = 120
var scale_factor: float = 1.0
var phase: float = 0.0
var line_color: Color = Color(0.36, 0.9, 1.0, 0.82)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var ul: int = maxi(2, u_lines)
	var vl: int = maxi(2, v_lines)
	var segs: int = maxi(12, samples_per_line)

	var immediate := ImmediateMesh.new()
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_set_color(line_color)

	for i in range(ul):
		var u: float = TAU * float(i) / float(ul)
		_add_u_contour(immediate, u, segs)

	for j in range(vl):
		var v: float = TAU * float(j) / float(vl)
		_add_v_contour(immediate, v, segs)

	immediate.surface_end()
	mesh = immediate


func _add_u_contour(immediate: ImmediateMesh, u: float, segs: int) -> void:
	var prev: Vector3 = _sample(u, 0.0)
	for i in range(1, segs + 1):
		var t: float = float(i) / float(segs)
		var v: float = TAU * t
		var curr: Vector3 = _sample(u, v)
		immediate.surface_add_vertex(prev)
		immediate.surface_add_vertex(curr)
		prev = curr


func _add_v_contour(immediate: ImmediateMesh, v: float, segs: int) -> void:
	var prev: Vector3 = _sample(0.0, v)
	for i in range(1, segs + 1):
		var t: float = float(i) / float(segs)
		var u: float = TAU * t
		var curr: Vector3 = _sample(u, v)
		immediate.surface_add_vertex(prev)
		immediate.surface_add_vertex(curr)
		prev = curr


func _sample(u: float, v: float) -> Vector3:
	var s: float = scale_factor
	var p: float = phase
	var surface_mode: String = String(surface_name).to_lower()

	if surface_mode == "torus":
		var r_major: float = 1.5 + 0.06 * sin(p * 0.8)
		var r_minor: float = 0.48 + 0.05 * cos(p * 1.1)
		var x: float = (r_major + r_minor * cos(v + p * 0.45)) * cos(u)
		var y: float = r_minor * sin(v + p * 0.45)
		var z: float = (r_major + r_minor * cos(v + p * 0.45)) * sin(u)
		return Vector3(x, y, z) * s

	if surface_mode == "mobius":
		var vv: float = (v / PI) - 1.0
		var x2: float = (1.35 + 0.45 * vv * cos(u * 0.5 + p * 0.35)) * cos(u)
		var y2: float = 0.45 * vv * sin(u * 0.5 + p * 0.35)
		var z2: float = (1.35 + 0.45 * vv * cos(u * 0.5 + p * 0.35)) * sin(u)
		return Vector3(x2, y2, z2) * s

	if surface_mode == "wave_sheet":
		var x3: float = lerpf(-2.3, 2.3, u / TAU)
		var z3: float = lerpf(-2.3, 2.3, v / TAU)
		var y3: float = 0.55 * sin(x3 * 1.2 + p) * cos(z3 * 1.1 - p * 0.7)
		return Vector3(x3, y3, z3) * s

	var dx: float = (1.5 + 0.48 * cos(v)) * cos(u)
	var dy: float = 0.48 * sin(v)
	var dz: float = (1.5 + 0.48 * cos(v)) * sin(u)
	return Vector3(dx, dy, dz) * s
