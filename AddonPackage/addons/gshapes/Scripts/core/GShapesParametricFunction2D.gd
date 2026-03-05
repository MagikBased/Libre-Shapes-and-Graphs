class_name GShapesParametricFunction2D
extends GShapesPolylineMobject

var t_min: float = 0.0
var t_max: float = TAU
var sample_count: int = 240
var function_name: StringName = &"lissajous"
var parametric_source: Callable


func _ready() -> void:
	rebuild_curve()


func rebuild_curve() -> void:
	var samples := maxi(2, sample_count)
	var pts := PackedVector2Array()
	pts.resize(samples)

	for i in range(samples):
		var alpha: float = 0.0 if samples <= 1 else float(i) / float(samples - 1)
		var t := lerpf(t_min, t_max, alpha)
		pts[i] = _sample_point(t)

	points = pts
	queue_redraw()


func _sample_point(t: float) -> Vector2:
	if parametric_source.is_valid():
		var v: Variant = parametric_source.call(t)
		if v is Vector2:
			return v as Vector2

	match String(function_name).to_lower():
		"circle":
			return Vector2(cos(t), sin(t)) * 160.0
		"spiral":
			var r := 26.0 * t
			return Vector2(cos(t), sin(t)) * r
		"lemniscate":
			var denom := 1.0 + pow(sin(t), 2.0)
			return Vector2(
				(260.0 * cos(t)) / denom,
				(145.0 * sin(t) * cos(t)) / denom
			)
		"lissajous":
			return Vector2(
				240.0 * sin(3.0 * t + 0.5),
				160.0 * sin(2.0 * t)
			)
		_:
			return Vector2(
				240.0 * sin(3.0 * t + 0.5),
				160.0 * sin(2.0 * t)
			)


func sample_point(t: float) -> Vector2:
	return _sample_point(t)



