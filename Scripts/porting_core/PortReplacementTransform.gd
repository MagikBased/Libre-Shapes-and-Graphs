class_name PortReplacementTransform
extends PortAnimation

var source: Node2D
var destination: Node2D
var match_position: bool = true

var source_start: Color = Color.WHITE
var destination_start: Color = Color.WHITE
var source_start_position: Vector2 = Vector2.ZERO
var destination_end_position: Vector2 = Vector2.ZERO


func _init(
	p_source: Node2D,
	p_destination: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_match_position: bool = true
) -> void:
	source = p_source
	destination = p_destination
	match_position = p_match_position
	super(null, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if source == null or destination == null:
		return

	source_start = source.modulate
	destination_start = destination.modulate
	source_start_position = source.position
	destination_end_position = destination.position

	if match_position:
		destination.position = source.position

	var dst := destination.modulate
	dst.a = 0.0
	destination.modulate = dst


func interpolate(alpha: float) -> void:
	if source == null or destination == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)

	var src := source_start
	src.a = source_start.a * (1.0 - t)
	source.modulate = src

	var dst := destination_start
	dst.a = destination_start.a * t
	destination.modulate = dst
	if match_position:
		destination.position = source_start_position.lerp(destination_end_position, t)
