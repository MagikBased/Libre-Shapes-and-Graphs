class_name PortIndicate
extends PortAnimation

var scale_factor: float = 1.2
var color_highlight: Color = Color.YELLOW

var _start_scale: Vector2 = Vector2.ONE
var _start_color: Color = Color.WHITE


func _init(
	p_target: Node2D,
	p_run_time: float = 0.8,
	p_rate_func_name: StringName = &"there_and_back",
	p_scale_factor: float = 1.2,
	p_color_highlight: Color = Color.YELLOW
) -> void:
	scale_factor = maxf(1.0, p_scale_factor)
	color_highlight = p_color_highlight
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_start_scale = target.scale
	_start_color = target.modulate


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t := clampf(alpha, 0.0, 1.0)
	target.scale = _start_scale.lerp(_start_scale * scale_factor, t)
	target.modulate = _start_color.lerp(color_highlight, t)


func on_finish() -> void:
	if target == null:
		return
	target.scale = _start_scale
	target.modulate = _start_color
