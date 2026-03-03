class_name Port3DScene
extends Node3D

var camera: Camera3D
var light: DirectionalLight3D
var orbit_enabled: bool = true
var pan_enabled: bool = true
var orbit_sensitivity: float = 0.01
var pan_sensitivity: float = 0.003
var zoom_sensitivity: float = 0.45
var min_distance: float = 2.0
var max_distance: float = 24.0
var target_point: Vector3 = Vector3.ZERO
var camera_fov: float = 75.0

var _yaw: float = 0.0
var _pitch: float = -0.25
var _distance: float = 8.0
var _is_orbit_dragging: bool = false
var _is_pan_dragging: bool = false


func _ready() -> void:
	ensure_default_camera_and_light()
	_sync_camera_from_orbit()


func ensure_default_camera_and_light() -> void:
	if camera == null:
		camera = Camera3D.new()
		camera.position = Vector3(0.0, 2.0, _distance)
		camera.fov = camera_fov
		camera.look_at(target_point)
		add_child(camera)

	if light == null:
		light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-35.0, 45.0, 0.0)
		add_child(light)


func set_orbit_pose(yaw: float, pitch: float, distance: float) -> void:
	_yaw = yaw
	_pitch = clampf(pitch, -1.2, 1.2)
	_distance = clampf(distance, min_distance, max_distance)
	_sync_camera_from_orbit()


func set_target(new_target: Vector3) -> void:
	target_point = new_target
	_sync_camera_from_orbit()


func orbit_by(delta_yaw: float, delta_pitch: float) -> void:
	_yaw += delta_yaw
	_pitch = clampf(_pitch + delta_pitch, -1.2, 1.2)
	_sync_camera_from_orbit()


func zoom_by(delta_distance: float) -> void:
	_distance = clampf(_distance + delta_distance, min_distance, max_distance)
	_sync_camera_from_orbit()


func set_camera_fov(new_fov: float) -> void:
	camera_fov = clampf(new_fov, 20.0, 120.0)
	if camera != null:
		camera.fov = camera_fov


func frame_aabb(bounds: AABB, padding: float = 1.2) -> void:
	if camera == null:
		return
	var center := bounds.get_center()
	var radius := bounds.size.length() * 0.5
	radius = maxf(0.5, radius * maxf(1.0, padding))
	var fov_radians := deg_to_rad(maxf(20.0, camera.fov))
	var dist := radius / maxf(0.001, tan(fov_radians * 0.5))
	target_point = center
	_distance = clampf(dist, min_distance, max_distance)
	_sync_camera_from_orbit()


func reset_camera_pose() -> void:
	_yaw = 0.0
	_pitch = -0.25
	_distance = 8.0
	target_point = Vector3.ZERO
	_sync_camera_from_orbit()


func _sync_camera_from_orbit() -> void:
	if camera == null:
		return
	var x := cos(_pitch) * sin(_yaw)
	var y := sin(_pitch)
	var z := cos(_pitch) * cos(_yaw)
	var dir := Vector3(x, y, z)
	camera.position = target_point + dir * _distance
	camera.look_at(target_point)


func _unhandled_input(event: InputEvent) -> void:
	if not orbit_enabled:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			_is_orbit_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			_is_pan_dragging = mb.pressed
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(-zoom_sensitivity)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(zoom_sensitivity)
	elif event is InputEventMouseMotion and _is_orbit_dragging:
		var mm := event as InputEventMouseMotion
		orbit_by(-mm.relative.x * orbit_sensitivity, -mm.relative.y * orbit_sensitivity)
	elif event is InputEventMouseMotion and _is_pan_dragging and pan_enabled and camera != null:
		var pan_event := event as InputEventMouseMotion
		var right := camera.global_transform.basis.x
		var up := camera.global_transform.basis.y
		var pan_scale := pan_sensitivity * _distance
		target_point += (-right * pan_event.relative.x + up * pan_event.relative.y) * pan_scale
		_sync_camera_from_orbit()
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_R:
			reset_camera_pose()
