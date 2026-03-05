class_name GShapesPathUtils
extends RefCounted


static func polyline_length(points: PackedVector2Array, closed: bool = false) -> float:
	if points.size() < 2:
		return 0.0
	var total: float = 0.0
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

	var clamped: float = clampf(alpha, 0.0, 1.0)
	var total: float = polyline_length(points, closed)
	if is_zero_approx(total):
		return points[0]

	var target_dist: float = clamped * total
	var traveled: float = 0.0
	var segment_count: int = points.size() if closed else points.size() - 1
	for i in range(segment_count):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		var seg_len: float = a.distance_to(b)
		if traveled + seg_len >= target_dist:
			var local_t: float = 0.0 if is_zero_approx(seg_len) else (target_dist - traveled) / seg_len
			return a.lerp(b, local_t)
		traveled += seg_len
	return points[points.size() - 1]


static func resample_polyline(points: PackedVector2Array, sample_count: int, closed: bool = false) -> PackedVector2Array:
	var count: int = maxi(2, sample_count)
	var out: PackedVector2Array = PackedVector2Array()
	out.resize(count)
	for i in range(count):
		var t: float = float(i) / float(count - 1)
		out[i] = sample_polyline(points, t, closed)
	return out



