class_name LsgEffects3D
extends RefCounted


static func pulse_scale(
	host: Node,
	target: Node3D,
	peak_scale: float = 1.2,
	run_time: float = 0.7,
	loops: int = 1
) -> Tween:
	if host == null:
		push_warning("GShapes.Effects3D.pulse_scale called without host node")
		var tree_null := Engine.get_main_loop() as SceneTree
		return tree_null.create_tween()
	if target == null:
		var wait_tween_null_target := host.create_tween()
		wait_tween_null_target.tween_interval(0.001)
		return wait_tween_null_target
	var safe_loops: int = maxi(1, loops)
	var safe_peak: float = maxf(1.01, peak_scale)
	var safe_time: float = maxf(0.05, run_time)
	var base_scale: Vector3 = target.scale
	var tween: Tween = host.create_tween()
	for i in range(safe_loops):
		tween.tween_property(target, "scale", base_scale * safe_peak, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(target, "scale", base_scale, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func spin_y(
	host: Node,
	target: Node3D,
	radians: float = TAU,
	run_time: float = 1.0
) -> Tween:
	if host == null:
		push_warning("GShapes.Effects3D.spin_y called without host node")
		var tree_null := Engine.get_main_loop() as SceneTree
		return tree_null.create_tween()
	if target == null:
		var wait_tween_null_target := host.create_tween()
		wait_tween_null_target.tween_interval(0.001)
		return wait_tween_null_target
	var tween: Tween = host.create_tween()
	tween.tween_property(target, "rotation:y", target.rotation.y + radians, maxf(0.05, run_time)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


static func arc_move_to(
	host: Node,
	target: Node3D,
	destination: Vector3,
	arc_height: float = 0.8,
	run_time: float = 1.0
) -> Tween:
	if host == null:
		push_warning("GShapes.Effects3D.arc_move_to called without host node")
		var tree_null := Engine.get_main_loop() as SceneTree
		return tree_null.create_tween()
	if target == null:
		var wait_tween_null_target := host.create_tween()
		wait_tween_null_target.tween_interval(0.001)
		return wait_tween_null_target
	var safe_time: float = maxf(0.1, run_time)
	var start: Vector3 = target.position
	var midpoint: Vector3 = start.lerp(destination, 0.5) + Vector3.UP * arc_height
	var tween: Tween = host.create_tween()
	tween.tween_property(target, "position", midpoint, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(target, "position", destination, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	return tween


static func staggered_pulse(
	host: Node,
	targets: Array[Node3D],
	lag: float = 0.08,
	peak_scale: float = 1.2,
	run_time: float = 0.45
) -> Tween:
	if host == null:
		push_warning("GShapes.Effects3D.staggered_pulse called without host node")
		var tree_null := Engine.get_main_loop() as SceneTree
		return tree_null.create_tween()
	var safe_lag: float = maxf(0.0, lag)
	var safe_time: float = maxf(0.05, run_time)
	var active_count: int = 0
	for i in range(targets.size()):
		var t: Node3D = targets[i]
		if t == null:
			continue
		active_count += 1
		var base: Vector3 = t.scale
		var pulse: Tween = host.create_tween()
		pulse.tween_interval(safe_lag * float(i))
		pulse.tween_property(t, "scale", base * maxf(1.01, peak_scale), safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		pulse.tween_property(t, "scale", base, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var wait_tween: Tween = host.create_tween()
	if active_count <= 0:
		wait_tween.tween_interval(0.001)
	else:
		wait_tween.tween_interval(safe_lag * float(active_count - 1) + safe_time)
	return wait_tween
