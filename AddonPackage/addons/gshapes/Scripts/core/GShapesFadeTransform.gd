class_name GShapesFadeTransform
extends GShapesAnimation

var source: Node2D
var destination: Node2D
var align_destination_to_source: bool = true

var _source_start_modulate: Color = Color.WHITE
var _destination_start_modulate: Color = Color.WHITE
var _destination_start_scale: Vector2 = Vector2.ONE
var _destination_from_scale: Vector2 = Vector2.ONE
var _source_start_position: Vector2 = Vector2.ZERO
var _destination_end_position: Vector2 = Vector2.ZERO


func _init(
	p_source: Node2D,
	p_destination: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_align_destination_to_source: bool = true
) -> void:
	source = p_source
	destination = p_destination
	align_destination_to_source = p_align_destination_to_source
	super(null, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if source == null or destination == null:
		return

	_source_start_modulate = source.modulate
	_destination_start_modulate = destination.modulate
	_destination_start_scale = destination.scale
	_source_start_position = source.position
	_destination_end_position = destination.position

	if align_destination_to_source:
		destination.position = source.position

	var d := destination.modulate
	d.a = 0.0
	destination.modulate = d
	_destination_from_scale = _destination_start_scale * 0.9
	destination.scale = _destination_from_scale


func interpolate(alpha: float) -> void:
	if source == null or destination == null:
		return

	var t: float = clampf(alpha, 0.0, 1.0)

	var s := _source_start_modulate
	s.a = _source_start_modulate.a * (1.0 - t)
	source.modulate = s

	var d := _destination_start_modulate
	d.a = _destination_start_modulate.a * t
	destination.modulate = d
	destination.scale = _destination_from_scale.lerp(_destination_start_scale, t)
	if align_destination_to_source:
		destination.position = _source_start_position.lerp(_destination_end_position, t)



