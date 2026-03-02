class_name Port3DScene
extends Node3D

var camera: Camera3D
var light: DirectionalLight3D
var orbit_enabled: bool = true
var orbit_sensitivity: float = 0.01
var zoom_sensitivity: float = 0.45
var min_distance: float = 2.0
var max_distance: float = 24.0
var target_point: Vector3 = Vector3.ZERO

var _yaw: float = 0.0
var _pitch: float = -0.25
var _distance: float = 8.0
var _is_orbit_dragging: bool = false


func _ready() -> void:
	ensure_default_camera_and_light()
	_sync_camera_from_orbit()


func ensure_default_camera_and_light() -> void:
	if camera == null:
		camera = Camera3D.new()
		camera.position = Vector3(0.0, 2.0, _distance)
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
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_distance = clampf(_distance - zoom_sensitivity, min_distance, max_distance)
			_sync_camera_from_orbit()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_distance = clampf(_distance + zoom_sensitivity, min_distance, max_distance)
			_sync_camera_from_orbit()
	elif event is InputEventMouseMotion and _is_orbit_dragging:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * orbit_sensitivity
		_pitch = clampf(_pitch - mm.relative.y * orbit_sensitivity, -1.2, 1.2)
		_sync_camera_from_orbit()
