class_name GShapesPointCloud3D
extends MultiMeshInstance3D

var x_min: float = -3.0
var x_max: float = 3.0
var z_min: float = -3.0
var z_max: float = 3.0
var x_steps: int = 28
var z_steps: int = 28
var cloud_name: StringName = &"helix"
var point_scale: float = 0.05
var point_color: Color = Color(0.95, 0.5, 0.25)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var total := maxi(1, x_steps) * maxi(1, z_steps)
	mm.instance_count = total

	var idx := 0
	for ix in range(maxi(1, x_steps)):
		for iz in range(maxi(1, z_steps)):
			var u := 0.0 if x_steps <= 1 else float(ix) / float(x_steps - 1)
			var v := 0.0 if z_steps <= 1 else float(iz) / float(z_steps - 1)
			var p := _sample_point(u, v)
			var t := Transform3D(Basis().scaled(Vector3.ONE * point_scale), p)
			mm.set_instance_transform(idx, t)
			mm.set_instance_color(idx, point_color)
			idx += 1

	multimesh = mm
	mm.mesh = SphereMesh.new()


func _sample_point(u: float, v: float) -> Vector3:
	var x := lerpf(x_min, x_max, u)
	var z := lerpf(z_min, z_max, v)
	match String(cloud_name).to_lower():
		"helix":
			var t := lerpf(0.0, TAU * 3.0, u)
			var r := lerpf(0.6, 2.4, v)
			return Vector3(cos(t) * r, lerpf(-1.8, 1.8, u), sin(t) * r)
		"wave":
			return Vector3(x, 0.45 * sin(x * 1.2) * cos(z * 1.2), z)
		"sphere":
			var theta := TAU * u
			var phi := PI * v
			var rr := 2.2
			return Vector3(
				rr * sin(phi) * cos(theta),
				rr * cos(phi),
				rr * sin(phi) * sin(theta)
			)
		_:
			return Vector3(x, 0.45 * sin(x * 1.2) * cos(z * 1.2), z)



