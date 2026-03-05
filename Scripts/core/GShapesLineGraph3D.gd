class_name GShapesLineGraph3D
extends Node3D

var curve_name: StringName = &"helix"
var sample_count: int = 140
var t_min: float = -PI
var t_max: float = PI
var phase: float = 0.0
var curve_scale: float = 1.0
var thickness: float = 0.07
var line_color: Color = Color(0.36, 0.9, 1.0, 0.88)
var show_markers: bool = false
var marker_scale: float = 0.06

var _tube: GShapesTubePath3D
var _markers: MultiMeshInstance3D
var _points: Array[Vector3] = []


func _ready() -> void:
	_ensure_nodes()
	rebuild()


func get_points() -> Array[Vector3]:
	return _points.duplicate()


func rebuild() -> void:
	_ensure_nodes()
	_points = _sample_points()

	_tube.radius = maxf(0.001, thickness)
	_tube.path_color = line_color
	_tube.radial_segments = 10
	_tube.closed_path = false
	_tube.set_points(_points)

	_rebuild_markers()


func _ensure_nodes() -> void:
	if _tube == null:
		_tube = GShapesTubePath3D.new()
		add_child(_tube)
	if _markers == null:
		_markers = MultiMeshInstance3D.new()
		add_child(_markers)


func _sample_points() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var count: int = maxi(4, sample_count)
	for i in range(count):
		var u: float = float(i) / float(count - 1)
		var t: float = lerpf(t_min, t_max, u)
		out.append(_curve_point(t))
	return out


func _curve_point(t: float) -> Vector3:
	var s: float = curve_scale
	var p: float = phase
	var n: String = String(curve_name).to_lower()

	if n == "helix":
		return Vector3(cos(t + p) * 1.6, t * 0.55, sin(t + p) * 1.6) * s
	if n == "lissajous":
		return Vector3(cos(2.0 * t + p), sin(3.0 * t + p * 0.8), sin(4.0 * t - p * 0.6)) * (1.65 * s)
	if n == "spiral":
		var r: float = 0.5 + 0.22 * (t - t_min)
		return Vector3(cos(t + p) * r, 0.45 * sin(1.4 * t + p * 0.4), sin(t + p) * r) * s
	if n == "figure8":
		return Vector3(sin(t + p), sin(2.0 * t - p * 0.5) * 0.55, sin(3.0 * t + p) * 0.65) * (1.8 * s)
	return Vector3(cos(t + p) * 1.6, t * 0.55, sin(t + p) * 1.6) * s


func _rebuild_markers() -> void:
	if not show_markers or _points.is_empty():
		_markers.multimesh = null
		return

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mm.mesh = mesh
	mm.instance_count = _points.size()

	var scale_factor: float = maxf(0.001, marker_scale)
	for i in range(_points.size()):
		var xf := Transform3D(Basis().scaled(Vector3.ONE * scale_factor), _points[i])
		mm.set_instance_transform(i, xf)
		mm.set_instance_color(i, line_color)

	_markers.multimesh = mm




