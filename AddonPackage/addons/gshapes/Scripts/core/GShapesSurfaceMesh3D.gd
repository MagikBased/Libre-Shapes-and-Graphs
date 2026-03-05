class_name GShapesSurfaceMesh3D
extends MeshInstance3D

var x_min: float = -3.0
var x_max: float = 3.0
var z_min: float = -3.0
var z_max: float = 3.0
var x_steps: int = 48
var z_steps: int = 48
var surface_name: StringName = &"wave"


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var xs := maxi(2, x_steps)
	var zs := maxi(2, z_steps)

	for ix in range(xs - 1):
		for iz in range(zs - 1):
			var u0 := float(ix) / float(xs - 1)
			var v0 := float(iz) / float(zs - 1)
			var u1 := float(ix + 1) / float(xs - 1)
			var v1 := float(iz + 1) / float(zs - 1)

			var p00 := _sample_point(u0, v0)
			var p10 := _sample_point(u1, v0)
			var p01 := _sample_point(u0, v1)
			var p11 := _sample_point(u1, v1)

			_add_triangle(st, p00, p10, p11)
			_add_triangle(st, p00, p11, p01)

	st.generate_normals()
	mesh = st.commit()


func _sample_point(u: float, v: float) -> Vector3:
	var x := lerpf(x_min, x_max, u)
	var z := lerpf(z_min, z_max, v)
	var y := _eval_height(x, z)
	return Vector3(x, y, z)


func _eval_height(x: float, z: float) -> float:
	match String(surface_name).to_lower():
		"wave":
			return 0.55 * sin(x) * cos(z)
		"ripple":
			var r := sqrt(x * x + z * z)
			return 0.6 * sin(2.0 * r) / maxf(1.0, r)
		"saddle":
			return 0.12 * (x * x - z * z)
		_:
			return 0.55 * sin(x) * cos(z)


func _add_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)



