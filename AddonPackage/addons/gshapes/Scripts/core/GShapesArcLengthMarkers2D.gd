class_name GShapesArcLengthMarkers2D
extends Node2D

var source_curve: GShapesPolylineMobject
var source_callable: Callable
var marker_count: int = 18
var marker_radius: float = 3.0
var marker_color: Color = Color(0.84, 1.0, 0.5, 0.9)
var include_endpoints: bool = true
var enabled_markers: bool = true

var _markers: PackedVector2Array = PackedVector2Array()


func _process(_delta: float) -> void:
	if not enabled_markers:
		_markers = PackedVector2Array()
		queue_redraw()
		return
	rebuild()


func rebuild() -> void:
	_markers = PackedVector2Array()
	var pts: PackedVector2Array = _sample_points()
	if pts.size() < 2:
		queue_redraw()
		return

	var count: int = maxi(1, marker_count)
	_markers.resize(count)
	for i in range(count):
		var t: float
		if include_endpoints:
			t = 0.0 if count <= 1 else float(i) / float(count - 1)
		else:
			t = float(i + 1) / float(count + 1)
		_markers[i] = GShapesPathUtils.sample_polyline(pts, t, false)

	queue_redraw()


func _sample_points() -> PackedVector2Array:
	if source_callable.is_valid():
		var v: Variant = source_callable.call()
		if v is PackedVector2Array:
			return v as PackedVector2Array
	if source_curve != null and is_instance_valid(source_curve):
		return source_curve.points
	return PackedVector2Array()


func _draw() -> void:
	for i in range(_markers.size()):
		draw_circle(_markers[i], marker_radius, marker_color)




