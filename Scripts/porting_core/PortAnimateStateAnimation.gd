class_name PortAnimateStateAnimation
extends PortAnimation

var animate_position: bool = false
var position_is_delta: bool = false
var end_position: Vector2 = Vector2.ZERO

var animate_scale: bool = false
var end_scale: Vector2 = Vector2.ONE

var animate_rotation: bool = false
var end_rotation: float = 0.0

var animate_color: bool = false
var end_color: Color = Color.WHITE

var animate_modulate: bool = false
var end_modulate: Color = Color.WHITE

var animate_value: bool = false
var end_value: float = 0.0

var _start_position: Vector2 = Vector2.ZERO
var _start_scale: Vector2 = Vector2.ONE
var _start_rotation: float = 0.0
var _start_color: Color = Color.WHITE
var _start_modulate: Color = Color.WHITE
var _start_value: float = 0.0


func _init(
	p_target: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	_start_position = target.position
	_start_scale = target.scale
	_start_rotation = target.rotation
	_start_modulate = target.modulate

	if animate_position and position_is_delta:
		end_position = _start_position + end_position

	if animate_color:
		_start_color = _get_color_property(target)

	if animate_value:
		_start_value = _get_value_property(target)


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var t := clampf(alpha, 0.0, 1.0)

	if animate_position:
		target.position = _start_position.lerp(end_position, t)
	if animate_scale:
		target.scale = _start_scale.lerp(end_scale, t)
	if animate_rotation:
		target.rotation = lerp_angle(_start_rotation, end_rotation, t)
	if animate_color:
		_set_color_property(target, _start_color.lerp(end_color, t))
	if animate_modulate:
		target.modulate = _start_modulate.lerp(end_modulate, t)
	if animate_value:
		_set_value_property(target, lerpf(_start_value, end_value, t))


func _has_property(obj: Object, property_name: StringName) -> bool:
	for p in obj.get_property_list():
		if p.has("name") and StringName(p["name"]) == property_name:
			return true
	return false


func _get_color_property(obj: Object) -> Color:
	if _has_property(obj, &"color"):
		var c = obj.get("color")
		if c is Color:
			return c
	return obj.get("modulate") if _has_property(obj, &"modulate") else Color.WHITE


func _set_color_property(obj: Object, color_value: Color) -> void:
	if _has_property(obj, &"color"):
		obj.set("color", color_value)
	elif _has_property(obj, &"modulate"):
		obj.set("modulate", color_value)


func _get_value_property(obj: Object) -> float:
	if obj.has_method("get_value"):
		return float(obj.call("get_value"))
	return 0.0


func _set_value_property(obj: Object, value: float) -> void:
	if obj.has_method("set_value"):
		obj.call("set_value", value)
