class_name LsgComplexFunctionPath2D
extends LsgPolylineMobject

var source_name: StringName = &"circle"
var function_name: StringName = &"square"
var sample_count: int = 260
var domain_scale: float = 1.25
var output_scale: float = 150.0
var morph_strength: float = 1.0


func _ready() -> void:
	rebuild_path()


func rebuild_path() -> void:
	var samples: int = maxi(3, sample_count)
	var pts := PackedVector2Array()
	pts.resize(samples)

	for i in range(samples):
		var t: float = float(i) / float(samples - 1)
		var z0: Vector2 = _sample_source(t) * domain_scale
		var z1: Vector2 = _map_complex(z0)
		var z: Vector2 = z0.lerp(z1, clampf(morph_strength, 0.0, 1.0))
		pts[i] = z * output_scale

	points = pts
	queue_redraw()


func _sample_source(t: float) -> Vector2:
	var theta: float = TAU * t
	match String(source_name).to_lower():
		"line":
			return Vector2(lerpf(-1.1, 1.1, t), 0.35 * sin(theta * 2.0))
		"lemniscate":
			var c: float = cos(theta)
			var s: float = sin(theta)
			var denom: float = 1.0 + s * s
			return Vector2((1.2 * c) / denom, (0.9 * s * c) / denom)
		"circle":
			return Vector2(cos(theta), sin(theta))
		_:
			return Vector2(cos(theta), sin(theta))


func _map_complex(z: Vector2) -> Vector2:
	var x: float = z.x
	var y: float = z.y
	match String(function_name).to_lower():
		"identity":
			return z
		"inverse":
			var denom: float = x * x + y * y
			if denom <= 0.0001:
				return Vector2.ZERO
			return Vector2(x / denom, -y / denom)
		"z_plus_inv":
			var inv := Vector2.ZERO
			var denom: float = x * x + y * y
			if denom > 0.0001:
				inv = Vector2(x / denom, -y / denom)
			return z + inv * 0.55
		"square":
			return Vector2(x * x - y * y, 2.0 * x * y)
		_:
			return Vector2(x * x - y * y, 2.0 * x * y)
