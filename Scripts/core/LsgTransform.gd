class_name LsgTransform
extends LsgAnimation

var animate_position: bool = false
var animate_scale: bool = false
var animate_rotation: bool = false

var start_position: Vector2 = Vector2.ZERO
var start_scale: Vector2 = Vector2.ONE
var start_rotation: float = 0.0

var end_position: Vector2 = Vector2.ZERO
var end_scale: Vector2 = Vector2.ONE
var end_rotation: float = 0.0


func _init(
	p_target: Node2D,
	p_end_position: Variant = null,
	p_end_scale: Variant = null,
	p_end_rotation: Variant = null,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	super(p_target, p_run_time, p_rate_func_name)

	if p_end_position is Vector2:
		animate_position = true
		end_position = p_end_position
	if p_end_scale is Vector2:
		animate_scale = true
		end_scale = p_end_scale
	if p_end_rotation is float:
		animate_rotation = true
		end_rotation = p_end_rotation


func on_begin() -> void:
	if target == null:
		return
	start_position = target.position
	start_scale = target.scale
	start_rotation = target.rotation

	if not animate_position:
		end_position = start_position
	if not animate_scale:
		end_scale = start_scale
	if not animate_rotation:
		end_rotation = start_rotation


func interpolate(alpha: float) -> void:
	if target == null:
		return

	var t: float = clampf(alpha, 0.0, 1.0)
	if animate_position:
		target.position = start_position.lerp(end_position, t)
	if animate_scale:
		target.scale = start_scale.lerp(end_scale, t)
	if animate_rotation:
		target.rotation = lerp_angle(start_rotation, end_rotation, t)
