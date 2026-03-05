class_name LsgFlowParticles2D
extends Node2D

var field_name: StringName = &"swirl"
var field_source: Callable
var strength: float = 1.0
var bounds: Rect2 = Rect2(Vector2(-420.0, -240.0), Vector2(840.0, 480.0))
var particle_count: int = 150
var step_size: float = 0.012
var particle_radius: float = 2.2
var particle_color: Color = Color(0.85, 0.95, 1.0, 0.75)
var max_magnitude: float = 2.7

var _particles: PackedVector2Array = PackedVector2Array()
var _initialized: bool = false


func _ready() -> void:
	reset_particles()


func _process(delta: float) -> void:
	if not _initialized:
		reset_particles()
	if _particles.is_empty():
		return
	var dt_scale: float = maxf(0.0001, delta * 60.0)
	for i in range(_particles.size()):
		var p: Vector2 = _particles[i]
		var v: Vector2 = _sample_field(p)
		var mag: float = v.length()
		if mag > max_magnitude:
			v = v.normalized() * max_magnitude
		p += v * step_size * 120.0 * dt_scale
		if not bounds.has_point(p):
			p = _respawn_point(i)
		_particles[i] = p
	queue_redraw()


func reset_particles() -> void:
	_particles = PackedVector2Array()
	var count: int = maxi(1, particle_count)
	_particles.resize(count)
	for i in range(count):
		_particles[i] = _respawn_point(i)
	_initialized = true
	queue_redraw()


func _respawn_point(index: int) -> Vector2:
	var rx: float = _hash01(index * 92821 + 17)
	var ry: float = _hash01(index * 68917 + 53)
	return Vector2(
		lerpf(bounds.position.x, bounds.position.x + bounds.size.x, rx),
		lerpf(bounds.position.y, bounds.position.y + bounds.size.y, ry)
	)


func _hash01(n: int) -> float:
	var x: int = n
	x = int((x ^ 61) ^ (x >> 16))
	x *= 9
	x = x ^ (x >> 4)
	x *= 668265261
	x = x ^ (x >> 15)
	var positive: int = x & 0x7fffffff
	return float(positive) / 2147483647.0


func _sample_field(p: Vector2) -> Vector2:
	if field_source.is_valid():
		var v: Variant = field_source.call(p)
		if v is Vector2:
			return (v as Vector2) * strength

	var px: float = p.x / 220.0
	var py: float = p.y / 220.0
	match String(field_name).to_lower():
		"radial":
			return Vector2(px, py) * strength
		"saddle":
			return Vector2(px, -py) * strength
		"sinus":
			return Vector2(sin(py * 2.4), cos(px * 1.9)) * strength
		"swirl":
			return Vector2(-py, px) * strength
		_:
			return Vector2(-py, px) * strength


func _draw() -> void:
	for i in range(_particles.size()):
		draw_circle(_particles[i], particle_radius, particle_color)
