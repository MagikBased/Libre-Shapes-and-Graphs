class_name PortMorphTransform
extends PortAnimation

var source: Node2D
var destination: Node2D

var _source_start_modulate: Color = Color.WHITE
var _destination_start_modulate: Color = Color.WHITE

var _source_start_polygon: PackedVector2Array = PackedVector2Array()
var _destination_polygon: PackedVector2Array = PackedVector2Array()
var _matched_vertex_count: int = 0


func _init(
	p_source: Node2D,
	p_destination: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth"
) -> void:
	source = p_source
	destination = p_destination
	super(null, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if source == null or destination == null:
		return

	_source_start_modulate = source.modulate
	_destination_start_modulate = destination.modulate

	var dst_mod: Color = destination.modulate
	dst_mod.a = 0.0
	destination.modulate = dst_mod

	if source is Polygon2D and destination is Polygon2D:
		_prepare_polygon_morph(source as Polygon2D, destination as Polygon2D)


func interpolate(alpha: float) -> void:
	if source == null or destination == null:
		return

	var t: float = clampf(alpha, 0.0, 1.0)
	_crossfade(t)
	_interpolate_polygons(t)


func _crossfade(t: float) -> void:
	var src: Color = _source_start_modulate
	src.a = _source_start_modulate.a * (1.0 - t)
	source.modulate = src

	var dst: Color = _destination_start_modulate
	dst.a = _destination_start_modulate.a * t
	destination.modulate = dst


func _prepare_polygon_morph(source_poly: Polygon2D, destination_poly: Polygon2D) -> void:
	_source_start_polygon = source_poly.polygon
	_destination_polygon = destination_poly.polygon
	_matched_vertex_count = maxi(_source_start_polygon.size(), _destination_polygon.size())
	if _matched_vertex_count < 3:
		return

	_source_start_polygon = _resample_vertices(_source_start_polygon, _matched_vertex_count)
	_destination_polygon = _resample_vertices(_destination_polygon, _matched_vertex_count)

	source_poly.polygon = _source_start_polygon
	destination_poly.polygon = _destination_polygon
	destination_poly.position = source_poly.position


func _interpolate_polygons(t: float) -> void:
	if _matched_vertex_count < 3:
		return
	if not (source is Polygon2D and destination is Polygon2D):
		return

	var source_poly: Polygon2D = source as Polygon2D
	var morphed: PackedVector2Array = PackedVector2Array()
	morphed.resize(_matched_vertex_count)

	for i in range(_matched_vertex_count):
		morphed[i] = _source_start_polygon[i].lerp(_destination_polygon[i], t)

	source_poly.polygon = morphed


func _resample_vertices(points: PackedVector2Array, target_count: int) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	if points.is_empty():
		return result
	if points.size() == target_count:
		return points

	result.resize(target_count)
	var n: int = points.size()
	for i in range(target_count):
		var pos: float = float(i) * float(n) / float(target_count)
		var a: int = int(floor(pos)) % n
		var b: int = (a + 1) % n
		var local_t: float = pos - floor(pos)
		result[i] = points[a].lerp(points[b], local_t)
	return result
