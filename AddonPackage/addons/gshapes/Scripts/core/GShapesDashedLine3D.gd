class_name GShapesDashedLine3D
extends MultiMeshInstance3D

var start_point: Vector3 = Vector3.ZERO
var end_point: Vector3 = Vector3(0.0, 0.0, 2.0)
var dash_length: float = 0.35
var gap_length: float = 0.2
var thickness: float = 0.04
var max_dashes: int = 400
var line_color: Color = Color(0.98, 0.72, 0.34)


func _ready() -> void:
	rebuild()


func set_points(start: Vector3, finish: Vector3) -> void:
	start_point = start
	end_point = finish
	rebuild()


func set_color(color: Color) -> void:
	line_color = color
	rebuild()


func rebuild() -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.instance_count = 0
	multimesh = mm

	var delta: Vector3 = end_point - start_point
	var total_length: float = delta.length()
	if total_length <= 0.0001:
		return

	var dash: float = maxf(0.001, dash_length)
	var gap: float = maxf(0.0, gap_length)
	var stride: float = dash + gap
	if stride <= 0.0001:
		return

	var dir: Vector3 = delta / total_length
	# Cylinder axis is +Y. Rotate +Y directly onto the segment direction.
	var line_basis: Basis = Basis(Quaternion(Vector3.UP, dir))
	var unit_cylinder := CylinderMesh.new()
	unit_cylinder.top_radius = 1.0
	unit_cylinder.bottom_radius = 1.0
	unit_cylinder.height = 1.0
	unit_cylinder.radial_segments = 10
	mm.mesh = unit_cylinder

	var segment_count: int = mini(max_dashes, int(ceil(total_length / stride)))
	mm.instance_count = segment_count

	for i in range(segment_count):
		var seg_start: float = float(i) * stride
		if seg_start >= total_length:
			mm.instance_count = i
			break
		var seg_end: float = minf(total_length, seg_start + dash)
		var seg_len: float = maxf(0.001, seg_end - seg_start)
		var seg_center: Vector3 = start_point + dir * ((seg_start + seg_end) * 0.5)
		# Cylinder height is along local +Y, so length scaling is applied on Y.
		var seg_basis: Basis = line_basis.scaled(Vector3(thickness, seg_len, thickness))
		var seg_xf := Transform3D(seg_basis, seg_center)
		mm.set_instance_transform(i, seg_xf)
		mm.set_instance_color(i, line_color)



