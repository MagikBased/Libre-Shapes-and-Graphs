class_name GShapesCameraTour3D
extends RefCounted

var _steps: Array[Dictionary] = []


func clear() -> void:
	_steps.clear()


func add_step(
	yaw: float,
	pitch: float,
	distance: float,
	target: Vector3,
	fov: float,
	duration: float = 0.9
) -> GShapesCameraTour3D:
	_steps.append({
		"yaw": yaw,
		"pitch": pitch,
		"distance": distance,
		"target": target,
		"fov": fov,
		"duration": maxf(0.01, duration),
	})
	return self


func add_hold(duration: float) -> GShapesCameraTour3D:
	_steps.append({
		"hold_only": true,
		"duration": maxf(0.01, duration),
	})
	return self


func is_empty() -> bool:
	return _steps.is_empty()


func play(scene: GShapes3DScene, loops: int = 1) -> Tween:
	var sequence: Tween = scene.create_tween()
	sequence.set_parallel(false)

	if _steps.is_empty():
		return sequence

	var loop_count: int = maxi(1, loops)
	for _loop_idx in range(loop_count):
		for step in _steps:
			var duration: float = float(step.get("duration", 0.9))
			if bool(step.get("hold_only", false)):
				sequence.tween_interval(duration)
				continue

			var target: Vector3 = step["target"]
			var yaw: float = float(step["yaw"])
			var pitch: float = float(step["pitch"])
			var distance: float = float(step["distance"])
			var fov: float = float(step["fov"])

			sequence.tween_callback(_apply_step.bind(scene, target, yaw, pitch, distance, fov, duration))
			sequence.tween_interval(duration)

	return sequence


func _apply_step(
	scene: GShapes3DScene,
	target: Vector3,
	yaw: float,
	pitch: float,
	distance: float,
	fov: float,
	duration: float
) -> void:
	scene.tween_target_to(target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scene.tween_orbit_to(yaw, pitch, distance, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scene.tween_fov_to(fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



