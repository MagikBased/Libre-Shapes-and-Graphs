class_name PortMoveTo
extends PortAnimation

var start_position: Vector2 = Vector2.ZERO
var end_position: Vector2 = Vector2.ZERO


func _init(
	p_target: Node2D,
	p_end_position: Vector2,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	end_position = p_end_position
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target != null:
		start_position = target.position


func interpolate(alpha: float) -> void:
	if target == null:
		return
	target.position = start_position.lerp(end_position, alpha)
