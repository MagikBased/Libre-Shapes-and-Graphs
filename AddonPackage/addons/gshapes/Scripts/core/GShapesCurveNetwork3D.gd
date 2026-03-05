class_name GShapesCurveNetwork3D
extends Node3D

var family_name: StringName = &"lissajous"
var curve_count: int = 6
var samples_per_curve: int = 120
var t_min: float = -PI
var t_max: float = PI
var thickness: float = 0.045
var curve_scale: float = 1.0
var phase: float = 0.0
var hue_start: float = 0.04
var hue_step: float = 0.12

var _curves: Array[GShapesTubePath3D] = []


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var count: int = maxi(1, curve_count)
	_ensure_curve_nodes(count)

	for i in range(_curves.size()):
		var tube: GShapesTubePath3D = _curves[i]
		if i >= count:
			tube.visible = false
			continue

		tube.visible = true
		tube.radius = maxf(0.001, thickness)
		tube.radial_segments = 10
		tube.closed_path = false
		tube.path_color = Color.from_hsv(fposmod(hue_start + hue_step * float(i), 1.0), 0.72, 0.98, 0.84)
		tube.set_points(_sample_curve(i))


func _ensure_curve_nodes(target_count: int) -> void:
	while _curves.size() < target_count:
		var tube: GShapesTubePath3D = GShapesTubePath3D.new()
		add_child(tube)
		_curves.append(tube)


func _sample_curve(index: int) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var count: int = maxi(4, samples_per_curve)
	for i in range(count):
		var u: float = float(i) / float(count - 1)
		var t: float = lerpf(t_min, t_max, u)
		out.append(_curve_point(index, t))
	return out


func _curve_point(index: int, t: float) -> Vector3:
	var idx: float = float(index)
	var p: float = phase
	var s: float = curve_scale
	var n: String = String(family_name).to_lower()

	if n == "lissajous":
		return Vector3(
			cos((2.0 + idx * 0.2) * t + p + idx * 0.35),
			sin((3.0 + idx * 0.16) * t - p * 0.7),
			sin((4.0 + idx * 0.12) * t + p * 0.5)
		) * (1.55 * s)
	if n == "helix_bundle":
		var r: float = 1.0 + idx * 0.18
		return Vector3(
			cos(t + p + idx * 0.45) * r,
			0.32 * t + sin(p + idx * 0.8) * 0.35,
			sin(t + p + idx * 0.45) * r
		) * s
	if n == "flower":
		var k: float = 2.0 + idx * 0.5
		var r2: float = 1.1 + 0.45 * sin(k * t + p + idx * 0.35)
		return Vector3(
			cos(t) * r2,
			0.55 * sin(2.0 * t + p + idx * 0.2),
			sin(t) * r2
		) * s

	return Vector3(
		cos((2.0 + idx * 0.2) * t + p + idx * 0.35),
		sin((3.0 + idx * 0.16) * t - p * 0.7),
		sin((4.0 + idx * 0.12) * t + p * 0.5)
	) * (1.55 * s)




