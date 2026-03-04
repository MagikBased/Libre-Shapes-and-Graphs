class_name PortVoxelGrid3D
extends MultiMeshInstance3D

var field_name: StringName = &"sphere"
var bounds: AABB = AABB(Vector3(-2.0, -2.0, -2.0), Vector3(4.0, 4.0, 4.0))
var x_steps: int = 20
var y_steps: int = 20
var z_steps: int = 20
var iso_level: float = 0.0
var cube_scale: float = 0.16
var max_voxels: int = 16000
var phase: float = 0.0
var voxel_color: Color = Color(0.34, 0.9, 1.0, 0.84)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = 0
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE
	mm.mesh = cube

	var xs: int = maxi(2, x_steps)
	var ys: int = maxi(2, y_steps)
	var zs: int = maxi(2, z_steps)
	var scale_factor: float = maxf(0.001, cube_scale)

	var voxels: Array[Vector3] = []
	for ix in range(xs):
		var ux: float = float(ix) / float(xs - 1)
		var x: float = lerpf(bounds.position.x, bounds.position.x + bounds.size.x, ux)
		for iy in range(ys):
			var uy: float = float(iy) / float(ys - 1)
			var y: float = lerpf(bounds.position.y, bounds.position.y + bounds.size.y, uy)
			for iz in range(zs):
				var uz: float = float(iz) / float(zs - 1)
				var z: float = lerpf(bounds.position.z, bounds.position.z + bounds.size.z, uz)
				var value: float = _field_value(x, y, z)
				if value <= iso_level:
					voxels.append(Vector3(x, y, z))
					if voxels.size() >= max_voxels:
						break
			if voxels.size() >= max_voxels:
				break
		if voxels.size() >= max_voxels:
			break

	mm.instance_count = voxels.size()
	for i in range(voxels.size()):
		var p: Vector3 = voxels[i]
		var xf := Transform3D(Basis().scaled(Vector3.ONE * scale_factor), p)
		mm.set_instance_transform(i, xf)
		mm.set_instance_color(i, voxel_color)

	multimesh = mm


func _field_value(x: float, y: float, z: float) -> float:
	var n: String = String(field_name).to_lower()
	if n == "sphere":
		return x * x + y * y + z * z - 2.5
	if n == "torus":
		var r_major: float = 1.35 + sin(phase * 0.8) * 0.12
		var r_minor: float = 0.5 + cos(phase * 1.1) * 0.06
		var q: float = sqrt(x * x + z * z) - r_major
		return q * q + y * y - r_minor * r_minor
	if n == "waves":
		return y - (0.55 * sin(x * 1.2 + phase) * cos(z * 1.1 - phase * 0.6))
	if n == "blob":
		var a: float = x * x + y * y + z * z
		return a + 0.4 * sin(2.2 * x + phase) + 0.35 * sin(2.0 * y - phase) + 0.3 * sin(2.4 * z + phase * 0.8) - 2.2
	return x * x + y * y + z * z - 2.5
