class_name GShapesTorusKnot3D
extends Node3D

var mode_name: StringName = &"trefoil"
var samples: int = 220
var major_radius: float = 2.1
var minor_radius: float = 0.62
var thickness: float = 0.045
var turns: float = 1.0
var phase: float = 0.0
var path_color: Color = Color(0.92, 0.66, 0.24, 0.9)

var _tube: GShapesTubePath3D


func _ready() -> void:
	_tube = GShapesTubePath3D.new()
	add_child(_tube)
	rebuild()


func rebuild() -> void:
	if _tube == null:
		return
	_tube.radius = maxf(0.001, thickness)
	_tube.radial_segments = 12
	_tube.path_color = path_color
	_tube.closed_path = true
	_tube.set_points(_sample_points())


func _sample_points() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var count: int = maxi(16, samples)
	var mode: String = String(mode_name).to_lower()
	var pq: Vector2i = _mode_to_pq(mode)
	var p: float = float(maxi(1, pq.x))
	var q: float = float(maxi(1, pq.y))
	var r_major: float = maxf(0.08, major_radius)
	var r_minor: float = maxf(0.03, minor_radius)
	var t_scale: float = maxf(0.1, turns)

	for i in range(count):
		var u: float = float(i) / float(count)
		var t: float = TAU * t_scale * u
		var center_r: float = r_major + r_minor * cos(q * t + phase * 0.75)
		var x: float = center_r * cos(p * t + phase)
		var z: float = center_r * sin(p * t + phase)
		var y: float = r_minor * sin(q * t + phase * 0.75)
		out.append(Vector3(x, y, z))
	return out


func _mode_to_pq(mode: String) -> Vector2i:
	if mode == "cinquefoil":
		return Vector2i(2, 5)
	if mode == "granny":
		return Vector2i(3, 4)
	return Vector2i(2, 3)




