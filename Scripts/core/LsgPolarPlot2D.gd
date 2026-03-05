class_name LsgPolarPlot2D
extends LsgPolylineMobject

var theta_min: float = 0.0
var theta_max: float = TAU
var sample_count: int = 280
var radial_scale: float = 170.0
var function_name: StringName = &"rose"
var radius_source: Callable


func _ready() -> void:
	rebuild_curve()


func rebuild_curve() -> void:
	var samples: int = maxi(3, sample_count)
	var pts := PackedVector2Array()
	pts.resize(samples)

	for i in range(samples):
		var alpha: float = float(i) / float(samples - 1)
		var theta: float = lerpf(theta_min, theta_max, alpha)
		pts[i] = _sample_point(theta)

	points = pts
	queue_redraw()


func _sample_radius(theta: float) -> float:
	if radius_source.is_valid():
		var v: Variant = radius_source.call(theta)
		if v is float:
			return maxf(0.0, float(v))
		if v is int:
			return maxf(0.0, float(v))

	match String(function_name).to_lower():
		"cardioid":
			return 1.0 + cos(theta)
		"spiral":
			return 0.15 + 0.2 * theta
		"limacon":
			return 0.7 + 0.95 * cos(theta)
		"rose":
			return absf(cos(4.0 * theta))
		_:
			return absf(cos(4.0 * theta))


func _sample_point(theta: float) -> Vector2:
	var r: float = _sample_radius(theta) * radial_scale
	return Vector2(cos(theta), sin(theta)) * r


func sample_point(theta: float) -> Vector2:
	return _sample_point(theta)
