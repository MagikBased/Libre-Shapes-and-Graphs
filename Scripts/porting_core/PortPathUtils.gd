class_name PortPathUtils
extends RefCounted


static func polyline_length(points: PackedVector2Array, closed: bool = false) -> float:
	if points.size() < 2:
		return 0.0
	var total := 0.0
	for i in range(points.size() - 1):
		total += points[i].distance_to(points[i + 1])
	if closed:
		total += points[points.size() - 1].distance_to(points[0])
	return total


static func sample_polyline(points: PackedVector2Array, alpha: float, closed: bool = false) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	if points.size() == 1:
		return points[0]

	var clamped := clampf(alpha, 0.0, 1.0)
	var total := polyline_length(points, closed)
	if is_zero_approx(total):
		return points[0]

	var target_dist := clamped * total
	var traveled := 0.0
	var segment_count := points.size() if closed else points.size() - 1
	for i in range(segment_count):
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		var seg_len := a.distance_to(b)
		if traveled + seg_len >= target_dist:
			var local_t := 0.0 if is_zero_approx(seg_len) else (target_dist - traveled) / seg_len
			return a.lerp(b, local_t)
		traveled += seg_len
	return points[points.size() - 1]


static func resample_polyline(points: PackedVector2Array, sample_count: int, closed: bool = false) -> PackedVector2Array:
	var count := maxi(2, sample_count)
	var out := PackedVector2Array()
	out.resize(count)
	for i in range(count):
		var t := float(i) / float(count - 1)
		out[i] = sample_polyline(points, t, closed)
	return out
