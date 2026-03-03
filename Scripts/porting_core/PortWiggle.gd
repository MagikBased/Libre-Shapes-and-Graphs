class_name PortWiggle
extends PortAnimation

var rotation_amplitude: float = deg_to_rad(12.0)
var scale_amplitude: float = 0.14
var wiggles: float = 3.0

var _start_scale: Vector2 = Vector2.ONE
var _start_rotation: float = 0.0


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_wiggles: float = 3.0,
	p_rotation_amplitude: float = deg_to_rad(12.0),
	p_scale_amplitude: float = 0.14
) -> void:
	wiggles = maxf(1.0, p_wiggles)
	rotation_amplitude = p_rotation_amplitude
	scale_amplitude = maxf(0.0, p_scale_amplitude)
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_start_scale = target.scale
	_start_rotation = target.rotation


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t := clampf(alpha, 0.0, 1.0)
	var envelope := PortRateFunctions.there_and_back(t)
	var phase := sin(TAU * wiggles * t)
	target.rotation = _start_rotation + rotation_amplitude * envelope * phase
	var s := 1.0 + scale_amplitude * envelope * absf(phase)
	target.scale = _start_scale * s


func on_finish() -> void:
	if target == null:
		return
	target.rotation = _start_rotation
	target.scale = _start_scale
