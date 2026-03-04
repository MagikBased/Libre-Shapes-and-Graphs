class_name PortCameraZoomTo
extends PortAnimation

var _start_zoom: Vector2 = Vector2.ONE
var _end_zoom: Vector2 = Vector2.ONE


func _init(
	p_camera: Camera2D,
	p_end_zoom: Vector2,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	_end_zoom = Vector2(maxf(0.001, p_end_zoom.x), maxf(0.001, p_end_zoom.y))
	super(p_camera, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null:
		return
	var camera: Camera2D = target as Camera2D
	if camera == null:
		return
	_start_zoom = camera.zoom


func interpolate(alpha: float) -> void:
	if target == null:
		return
	var camera: Camera2D = target as Camera2D
	if camera == null:
		return
	var t: float = clampf(alpha, 0.0, 1.0)
	camera.zoom = _start_zoom.lerp(_end_zoom, t)
