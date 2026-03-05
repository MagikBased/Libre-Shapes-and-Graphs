class_name GShapesFourierCurve2D
extends GShapesPolylineMobject

var sample_count: int = 360
var base_scale: float = 125.0
var morph_strength: float = 1.0

var harmonic_1_amp: float = 1.0
var harmonic_1_freq: float = 1.0
var harmonic_1_phase: float = 0.0

var harmonic_2_amp: float = 0.38
var harmonic_2_freq: float = 2.0
var harmonic_2_phase: float = 0.7

var harmonic_3_amp: float = 0.24
var harmonic_3_freq: float = 3.0
var harmonic_3_phase: float = -0.45


func _ready() -> void:
	rebuild_curve()


func rebuild_curve() -> void:
	var samples: int = maxi(3, sample_count)
	var pts := PackedVector2Array()
	pts.resize(samples)

	for i in range(samples):
		var t: float = TAU * (float(i) / float(samples - 1))
		pts[i] = _sample_point(t) * base_scale

	points = pts
	queue_redraw()


func _sample_point(theta: float) -> Vector2:
	var x: float = 0.0
	var y: float = 0.0
	x += harmonic_1_amp * cos(harmonic_1_freq * theta + harmonic_1_phase)
	y += harmonic_1_amp * sin(harmonic_1_freq * theta + harmonic_1_phase)
	x += harmonic_2_amp * cos(harmonic_2_freq * theta + harmonic_2_phase)
	y += harmonic_2_amp * sin(harmonic_2_freq * theta + harmonic_2_phase)
	x += harmonic_3_amp * cos(harmonic_3_freq * theta + harmonic_3_phase)
	y += harmonic_3_amp * sin(harmonic_3_freq * theta + harmonic_3_phase)
	var full: Vector2 = Vector2(x, y)
	var base: Vector2 = Vector2(cos(theta), sin(theta))
	return base.lerp(full, clampf(morph_strength, 0.0, 1.0))



