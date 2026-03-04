class_name PortBezierCurve3D
extends Node3D

var control_points: Array[Vector3] = [
	Vector3(-2.2, -0.6, -1.2),
	Vector3(-0.8, 1.6, -0.8),
	Vector3(0.8, -1.4, 0.8),
	Vector3(2.2, 0.7, 1.2),
]
var samples_per_segment: int = 48
var curve_radius: float = 0.08
var curve_color: Color = Color(0.38, 0.9, 1.0, 0.88)

var _tube: PortTubePath3D
var _sampled_points: Array[Vector3] = []


func _ready() -> void:
	_ensure_tube()
	rebuild()


func set_control_points(points: Array[Vector3]) -> void:
	control_points = points.duplicate()
	rebuild()


func get_sampled_points() -> Array[Vector3]:
	return _sampled_points.duplicate()


func rebuild() -> void:
	_ensure_tube()
	_tube.radius = curve_radius
	_tube.path_color = curve_color
	_tube.radial_segments = 10
	_tube.closed_path = false

	_sampled_points = _sample_curve()
	_tube.set_points(_sampled_points)


func _sample_curve() -> Array[Vector3]:
	var out: Array[Vector3] = []
	if control_points.size() < 4:
		return out

	var seg_samples: int = maxi(4, samples_per_segment)
	var seg_count: int = int(floor(float(control_points.size() - 1) / 3.0))
	for seg in range(seg_count):
		var i0: int = seg * 3
		var p0: Vector3 = control_points[i0]
		var p1: Vector3 = control_points[i0 + 1]
		var p2: Vector3 = control_points[i0 + 2]
		var p3: Vector3 = control_points[i0 + 3]

		for i in range(seg_samples):
			if seg > 0 and i == 0:
				continue
			var t: float = float(i) / float(seg_samples - 1)
			out.append(_cubic_bezier(p0, p1, p2, p3, t))
	return out


func _cubic_bezier(a: Vector3, b: Vector3, c: Vector3, d: Vector3, t: float) -> Vector3:
	var u: float = 1.0 - t
	var tt: float = t * t
	var uu: float = u * u
	var uuu: float = uu * u
	var ttt: float = tt * t
	return a * uuu + b * (3.0 * uu * t) + c * (3.0 * u * tt) + d * ttt


func _ensure_tube() -> void:
	if _tube != null:
		return
	_tube = PortTubePath3D.new()
	add_child(_tube)
