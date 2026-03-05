class_name GShapesTransformMatchingShapes
extends GShapesMorphTransform

var normalize_size: bool = true


func _init(
	p_source: Node2D,
	p_destination: Node2D,
	p_run_time: float = 1.0,
	p_rate_func_name: StringName = &"smooth",
	p_normalize_size: bool = true
) -> void:
	normalize_size = p_normalize_size
	super(p_source, p_destination, p_run_time, p_rate_func_name)


func on_begin() -> void:
	super.on_begin()
	if source == null or destination == null:
		return

	var src_rect := _estimate_bounds(source)
	var dst_rect := _estimate_bounds(destination)
	var src_center := src_rect.position + src_rect.size * 0.5
	var dst_center := dst_rect.position + dst_rect.size * 0.5

	destination.position += (source.position + src_center) - (destination.position + dst_center)

	if normalize_size:
		var src_diag := maxf(1.0, src_rect.size.length())
		var dst_diag := maxf(1.0, dst_rect.size.length())
		var ratio := src_diag / dst_diag
		destination.scale *= Vector2(ratio, ratio)


func _estimate_bounds(node: Node2D) -> Rect2:
	if node is Polygon2D:
		var p := node as Polygon2D
		if p.polygon.is_empty():
			return Rect2(Vector2.ZERO, Vector2.ONE)
		var min_v := p.polygon[0]
		var max_v := p.polygon[0]
		for v in p.polygon:
			min_v.x = minf(min_v.x, v.x)
			min_v.y = minf(min_v.y, v.y)
			max_v.x = maxf(max_v.x, v.x)
			max_v.y = maxf(max_v.y, v.y)
		return Rect2(min_v, max_v - min_v)
	if node is Circle:
		var c := node as Circle
		var r := c.size.x * 0.5
		return Rect2(Vector2(-r, -r), Vector2(2.0 * r, 2.0 * r))
	if node is Rectangle:
		var rr := node as Rectangle
		return Rect2(-rr.size * 0.5, rr.size)
	return Rect2(Vector2(-24.0, -24.0), Vector2(48.0, 48.0))



