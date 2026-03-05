class_name GShapes3DScene
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
		add_child(camera)
		camera.look_at(target_point)

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
	var frame_pose: Dictionary = _compute_frame_pose(bounds, padding)
	var frame_target: Vector3 = frame_pose["target"]
	var frame_distance: float = frame_pose["distance"]
	target_point = frame_target
	_distance = frame_distance
	_sync_camera_from_orbit()


func reset_camera_pose() -> void:
	_yaw = 0.0
	_pitch = -0.25
	_distance = 8.0
	target_point = Vector3.ZERO
	_sync_camera_from_orbit()


func frame_nodes(nodes: Array, padding: float = 1.2) -> bool:
	var aabb: AABB = _compute_nodes_aabb(nodes)
	if aabb.size.length() <= 0.0001:
		return false
	frame_aabb(aabb, padding)
	return true


func tween_target_to(new_target: Vector3, duration: float = 0.8) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_method(_set_target_from_tween, target_point, new_target, maxf(0.01, duration))
	return tween


func tween_orbit_to(
	new_yaw: float,
	new_pitch: float,
	new_distance: float,
	duration: float = 0.8
) -> Tween:
	var tween: Tween = create_tween()
	var from_pose: Vector3 = Vector3(_yaw, _pitch, _distance)
	var to_pose: Vector3 = Vector3(new_yaw, clampf(new_pitch, -1.2, 1.2), clampf(new_distance, min_distance, max_distance))
	tween.tween_method(_set_orbit_from_tween, from_pose, to_pose, maxf(0.01, duration))
	return tween


func tween_fov_to(new_fov: float, duration: float = 0.8) -> Tween:
	var tween: Tween = create_tween()
	var from_fov: float = camera_fov
	var to_fov: float = clampf(new_fov, 20.0, 120.0)
	tween.tween_method(_set_fov_from_tween, from_fov, to_fov, maxf(0.01, duration))
	return tween


func tween_frame_to_aabb(bounds: AABB, padding: float = 1.2, duration: float = 0.9) -> Tween:
	var frame_pose: Dictionary = _compute_frame_pose(bounds, padding)
	var target: Vector3 = frame_pose["target"]
	var distance: float = frame_pose["distance"]
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(_set_target_from_tween, target_point, target, maxf(0.01, duration))
	tween.tween_method(_set_distance_from_tween, _distance, distance, maxf(0.01, duration))
	return tween


func tween_frame_to_nodes(nodes: Array, padding: float = 1.2, duration: float = 0.9) -> Tween:
	var aabb: AABB = _compute_nodes_aabb(nodes)
	if aabb.size.length() <= 0.0001:
		return create_tween()
	return tween_frame_to_aabb(aabb, padding, duration)


func get_orbit_pose() -> Dictionary:
	return {
		"yaw": _yaw,
		"pitch": _pitch,
		"distance": _distance,
		"target": target_point,
		"fov": camera_fov
	}


func _sync_camera_from_orbit() -> void:
	if camera == null:
		return
	var x := cos(_pitch) * sin(_yaw)
	var y := sin(_pitch)
	var z := cos(_pitch) * cos(_yaw)
	var dir := Vector3(x, y, z)
	camera.position = target_point + dir * _distance
	camera.look_at(target_point)


func _compute_frame_pose(bounds: AABB, padding: float) -> Dictionary:
	var center: Vector3 = bounds.get_center()
	var radius: float = bounds.size.length() * 0.5
	radius = maxf(0.5, radius * maxf(1.0, padding))
	var fov_radians: float = deg_to_rad(maxf(20.0, camera_fov))
	var distance: float = radius / maxf(0.001, tan(fov_radians * 0.5))
	distance = clampf(distance, min_distance, max_distance)
	return {
		"target": center,
		"distance": distance
	}


func _set_target_from_tween(value: Vector3) -> void:
	target_point = value
	_sync_camera_from_orbit()


func _set_orbit_from_tween(value: Vector3) -> void:
	_yaw = value.x
	_pitch = clampf(value.y, -1.2, 1.2)
	_distance = clampf(value.z, min_distance, max_distance)
	_sync_camera_from_orbit()


func _set_distance_from_tween(value: float) -> void:
	_distance = clampf(value, min_distance, max_distance)
	_sync_camera_from_orbit()


func _set_fov_from_tween(value: float) -> void:
	set_camera_fov(value)
	_sync_camera_from_orbit()


func _compute_nodes_aabb(nodes: Array) -> AABB:
	var has_bounds: bool = false
	var min_v: Vector3 = Vector3.ZERO
	var max_v: Vector3 = Vector3.ZERO
	for item in nodes:
		if not (item is Node3D):
			continue
		var node: Node3D = item as Node3D
		var node_aabb: AABB = _compute_node_aabb(node)
		if node_aabb.size.length() <= 0.0001:
			continue
		var a_min: Vector3 = node_aabb.position
		var a_max: Vector3 = node_aabb.position + node_aabb.size
		if not has_bounds:
			min_v = a_min
			max_v = a_max
			has_bounds = true
		else:
			min_v.x = minf(min_v.x, a_min.x)
			min_v.y = minf(min_v.y, a_min.y)
			min_v.z = minf(min_v.z, a_min.z)
			max_v.x = maxf(max_v.x, a_max.x)
			max_v.y = maxf(max_v.y, a_max.y)
			max_v.z = maxf(max_v.z, a_max.z)
	if not has_bounds:
		return AABB(Vector3.ZERO, Vector3.ZERO)
	return AABB(min_v, max_v - min_v)


func _compute_node_aabb(node: Node3D) -> AABB:
	var has_bounds: bool = false
	var min_v: Vector3 = node.global_position
	var max_v: Vector3 = node.global_position
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current is Node3D:
			var c3d: Node3D = current as Node3D
			var local_aabb: AABB = _try_get_local_aabb(c3d)
			var world_aabb: AABB = _transform_aabb(local_aabb, c3d.global_transform)
			var a_min: Vector3 = world_aabb.position
			var a_max: Vector3 = world_aabb.position + world_aabb.size
			if not has_bounds:
				min_v = a_min
				max_v = a_max
				has_bounds = true
			else:
				min_v.x = minf(min_v.x, a_min.x)
				min_v.y = minf(min_v.y, a_min.y)
				min_v.z = minf(min_v.z, a_min.z)
				max_v.x = maxf(max_v.x, a_max.x)
				max_v.y = maxf(max_v.y, a_max.y)
				max_v.z = maxf(max_v.z, a_max.z)
		for child in current.get_children():
			stack.append(child)
	if not has_bounds:
		return AABB(node.global_position, Vector3.ZERO)
	return AABB(min_v, max_v - min_v)


func _try_get_local_aabb(node: Node3D) -> AABB:
	if node is MeshInstance3D:
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node.mesh != null:
			return mesh_node.mesh.get_aabb()
		return AABB(Vector3.ZERO, Vector3.ZERO)
	if node is MultiMeshInstance3D:
		var mm_node: MultiMeshInstance3D = node as MultiMeshInstance3D
		if mm_node.multimesh != null:
			var mm_aabb: AABB = mm_node.multimesh.get_aabb()
			return mm_aabb
		return AABB(Vector3.ZERO, Vector3.ZERO)
	return AABB(Vector3.ZERO, Vector3.ZERO)


func _transform_aabb(local_aabb: AABB, xform: Transform3D) -> AABB:
	var p0: Vector3 = local_aabb.position
	var p1: Vector3 = local_aabb.position + local_aabb.size
	var corners: Array[Vector3] = [
		Vector3(p0.x, p0.y, p0.z),
		Vector3(p1.x, p0.y, p0.z),
		Vector3(p0.x, p1.y, p0.z),
		Vector3(p0.x, p0.y, p1.z),
		Vector3(p1.x, p1.y, p0.z),
		Vector3(p1.x, p0.y, p1.z),
		Vector3(p0.x, p1.y, p1.z),
		Vector3(p1.x, p1.y, p1.z),
	]
	var has_point: bool = false
	var min_v: Vector3 = Vector3.ZERO
	var max_v: Vector3 = Vector3.ZERO
	for corner in corners:
		var wc: Vector3 = xform * corner
		if not has_point:
			min_v = wc
			max_v = wc
			has_point = true
		else:
			min_v.x = minf(min_v.x, wc.x)
			min_v.y = minf(min_v.y, wc.y)
			min_v.z = minf(min_v.z, wc.z)
			max_v.x = maxf(max_v.x, wc.x)
			max_v.y = maxf(max_v.y, wc.y)
			max_v.z = maxf(max_v.z, wc.z)
	return AABB(min_v, max_v - min_v)


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



