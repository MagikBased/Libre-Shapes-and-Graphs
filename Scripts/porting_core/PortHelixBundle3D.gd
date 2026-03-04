class_name PortHelixBundle3D
extends Node3D

var mode_name: StringName = &"uniform"
var helix_count: int = 7
var samples_per_helix: int = 140
var turns: float = 3.5
var bundle_radius: float = 1.6
var strand_wave: float = 0.22
var vertical_span: float = 4.4
var thickness: float = 0.035
var phase: float = 0.0
var hue_start: float = 0.03
var hue_step: float = 0.11

var _helixes: Array[PortTubePath3D] = []


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	var count: int = maxi(1, helix_count)
	_ensure_helix_nodes(count)

	for i in range(_helixes.size()):
		var tube: PortTubePath3D = _helixes[i]
		if i >= count:
			tube.visible = false
			continue

		tube.visible = true
		tube.radius = maxf(0.001, thickness)
		tube.radial_segments = 10
		tube.closed_path = false
		tube.path_color = Color.from_hsv(fposmod(hue_start + hue_step * float(i), 1.0), 0.7, 0.98, 0.88)
		tube.set_points(_sample_helix(i))


func _ensure_helix_nodes(target_count: int) -> void:
	while _helixes.size() < target_count:
		var tube := PortTubePath3D.new()
		add_child(tube)
		_helixes.append(tube)


func _sample_helix(index: int) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var count: int = maxi(6, samples_per_helix)
	var total_turns: float = maxf(0.25, turns)
	for i in range(count):
		var u: float = float(i) / float(count - 1)
		var t: float = TAU * total_turns * u
		out.append(_helix_point(index, t, u))
	return out


func _helix_point(index: int, t: float, u: float) -> Vector3:
	var idx: float = float(index)
	var strand_count: float = float(maxi(1, helix_count))
	var base_angle: float = TAU * idx / strand_count
	var p: float = phase
	var mode: String = String(mode_name).to_lower()
	var radial: float = maxf(0.05, bundle_radius)
	var strand_angle: float = base_angle + t + p

	if mode == "alternating":
		var direction: float = 1.0 if (index % 2) == 0 else -1.0
		strand_angle = base_angle + direction * (t + p * 1.2)
		radial *= 1.0 + 0.18 * sin(2.0 * t + idx * 0.8 + p)
	elif mode == "braid":
		strand_angle = base_angle + t + p + 0.35 * sin(3.0 * TAU * u + idx * 0.7)
		radial *= 1.0 + 0.24 * sin(2.0 * t + idx * 0.35 + p * 0.7)
	else:
		strand_angle = base_angle + t + p

	radial += strand_wave * sin(1.6 * t + idx * 0.5 + p * 0.6)
	var span: float = maxf(0.05, vertical_span)
	var y: float = lerpf(-span * 0.5, span * 0.5, u) + 0.2 * sin(0.55 * t + idx * 0.5 + p)
	return Vector3(cos(strand_angle) * radial, y, sin(strand_angle) * radial)
