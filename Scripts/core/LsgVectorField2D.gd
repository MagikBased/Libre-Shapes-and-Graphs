class_name LsgVectorField2D
extends Node2D

var x_min: float = -5.0
var x_max: float = 5.0
var y_min: float = -3.0
var y_max: float = 3.0
var step: float = 1.0

var arrow_scale: float = 42.0
var max_vector_length: float = 2.2
var strength: float = 1.0
var dynamic_update: bool = true

var function_name: StringName = &"rotational"
var arrow_color: Color = Color(0.55, 0.9, 1.0, 0.9)
var vector_source: Callable

var _origins: Array[Vector2] = []
var _arrows: Array[LsgArrow2D] = []


func _ready() -> void:
	rebuild()


func _process(_delta: float) -> void:
	if dynamic_update:
		_refresh_vectors()


func rebuild() -> void:
	for arrow in _arrows:
		if is_instance_valid(arrow):
			arrow.queue_free()
	_arrows.clear()
	_origins.clear()

	var sx := maxf(0.001, step)
	var sy := sx
	var y := y_min
	while y <= y_max + 0.0001:
		var x := x_min
		while x <= x_max + 0.0001:
			var origin := Vector2(x, y)
			var arrow: LsgArrow2D = GShapes.Arrow2D.new()
			arrow.color = arrow_color
			arrow.stroke_width = 2.5
			arrow.tip_length = 10.0
			arrow.tip_angle_deg = 30.0
			add_child(arrow)
			_origins.append(origin)
			_arrows.append(arrow)
			x += sx
		y += sy

	_refresh_vectors()


func set_strength(new_strength: float) -> void:
	strength = new_strength
	_refresh_vectors()


func set_vector_source(source: Callable) -> void:
	vector_source = source
	_refresh_vectors()


func _refresh_vectors() -> void:
	var count := mini(_origins.size(), _arrows.size())
	for i in range(count):
		var origin := _origins[i]
		var vec := _sample_vector(origin)
		var mag := vec.length()
		if mag > max_vector_length and mag > 0.0001:
			vec = vec / mag * max_vector_length
			mag = max_vector_length

		var arrow := _arrows[i]
		var start := origin * arrow_scale
		var end := (origin + vec) * arrow_scale
		arrow.set_points(start, end)
		var alpha := 0.35 + 0.65 * clampf(mag / maxf(0.0001, max_vector_length), 0.0, 1.0)
		arrow.color = Color(arrow_color.r, arrow_color.g, arrow_color.b, alpha)


func _sample_vector(p: Vector2) -> Vector2:
	if vector_source.is_valid():
		var v: Variant = vector_source.call(p)
		if v is Vector2:
			return (v as Vector2) * strength

	match String(function_name).to_lower():
		"rotational":
			return Vector2(-p.y, p.x) * 0.55 * strength
		"saddle":
			return Vector2(p.x, -p.y) * 0.5 * strength
		"sink":
			return (-p) * 0.45 * strength
		"source":
			return p * 0.45 * strength
		"swirl":
			var r2 := maxf(0.25, p.length_squared())
			return Vector2(-p.y, p.x) / r2 * 1.1 * strength
		_:
			return Vector2(-p.y, p.x) * 0.55 * strength
