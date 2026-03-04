class_name PortImplicitSurface3D
extends MultiMeshInstance3D

var surface_name: StringName = &"sphere"
var x_min: float = -2.2
var x_max: float = 2.2
var y_min: float = -2.2
var y_max: float = 2.2
var z_min: float = -2.2
var z_max: float = 2.2
var x_steps: int = 34
var y_steps: int = 34
var z_steps: int = 34
var iso_threshold: float = 0.08
var point_scale: float = 0.035
var max_points: int = 24000
var phase: float = 0.0
var point_color: Color = Color(0.36, 0.9, 1.0, 0.86)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = 0

	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mm.mesh = mesh

	var xs: int = maxi(2, x_steps)
	var ys: int = maxi(2, y_steps)
	var zs: int = maxi(2, z_steps)
	var threshold: float = maxf(0.0001, absf(iso_threshold))
	var scale_factor: float = maxf(0.001, point_scale)

	var points: Array[Vector3] = []
	for ix in range(xs):
		var ux: float = float(ix) / float(xs - 1)
		var x: float = lerpf(x_min, x_max, ux)
		for iy in range(ys):
			var uy: float = float(iy) / float(ys - 1)
			var y: float = lerpf(y_min, y_max, uy)
			for iz in range(zs):
				var uz: float = float(iz) / float(zs - 1)
				var z: float = lerpf(z_min, z_max, uz)
				var v: float = _implicit_value(x, y, z)
				if absf(v) <= threshold:
					points.append(Vector3(x, y, z))
					if points.size() >= max_points:
						break
			if points.size() >= max_points:
				break
		if points.size() >= max_points:
			break

	mm.instance_count = points.size()
	for i in range(points.size()):
		var p: Vector3 = points[i]
		var xf := Transform3D(Basis().scaled(Vector3.ONE * scale_factor), p)
		mm.set_instance_transform(i, xf)
		mm.set_instance_color(i, point_color)

	multimesh = mm


func _implicit_value(x: float, y: float, z: float) -> float:
	var n: String = String(surface_name).to_lower()
	if n == "sphere":
		return x * x + y * y + z * z - 2.15
	if n == "torus":
		var r_major: float = 1.35 + sin(phase * 0.7) * 0.12
		var r_minor: float = 0.52 + cos(phase * 1.1) * 0.06
		var q: float = sqrt(x * x + z * z) - r_major
		return q * q + y * y - r_minor * r_minor
	if n == "gyroid":
		return sin(x + phase) * cos(y) + sin(y + phase * 0.8) * cos(z) + sin(z + phase * 0.6) * cos(x)
	if n == "heart":
		var a: float = x * x + (9.0 / 4.0) * y * y + z * z - 1.0
		return a * a * a - x * x * z * z * z - (9.0 / 80.0) * y * y * z * z * z
	return x * x + y * y + z * z - 2.15
