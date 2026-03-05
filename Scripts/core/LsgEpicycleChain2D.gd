class_name LsgEpicycleChain2D
extends Node2D

var amplitudes: Array[float] = [1.0, 0.46, 0.28, 0.18]
var frequencies: Array[float] = [1.0, -2.0, 3.0, -4.0]
var phases: Array[float] = [0.0, 1.1, -0.7, 0.45]
var scale_factor: float = 120.0
var current_time: float = 0.0
var chain_color: Color = Color(0.72, 0.88, 1.0, 0.92)
var guide_color: Color = Color(0.65, 0.82, 1.0, 0.35)
var endpoint_color: Color = Color(1.0, 0.72, 0.35, 0.95)
var line_width: float = 2.0
var guide_width: float = 1.1


func set_time(t: float) -> void:
	current_time = t
	queue_redraw()


func endpoint_local_at(t: float) -> Vector2:
	var count: int = _term_count()
	var p := Vector2.ZERO
	for i in range(count):
		var amp: float = amplitudes[i]
		var freq: float = frequencies[i]
		var phase: float = phases[i]
		var angle: float = freq * t + phase
		p += Vector2(cos(angle), sin(angle)) * (amp * scale_factor)
	return p


func _term_count() -> int:
	return mini(amplitudes.size(), mini(frequencies.size(), phases.size()))


func _draw() -> void:
	var count: int = _term_count()
	if count <= 0:
		return

	var from := Vector2.ZERO
	for i in range(count):
		var amp: float = amplitudes[i]
		var freq: float = frequencies[i]
		var phase: float = phases[i]
		var radius: float = amp * scale_factor
		var angle: float = freq * current_time + phase
		var to: Vector2 = from + Vector2(cos(angle), sin(angle)) * radius

		draw_arc(from, radius, 0.0, TAU, 72, guide_color, guide_width, true)
		draw_line(from, to, chain_color, line_width, true)
		from = to

	draw_circle(from, 5.0, endpoint_color)
