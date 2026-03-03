class_name PortBrace2D
extends PortObject2D

enum BraceSide {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
}

var target_node: Node
var side: BraceSide = BraceSide.BOTTOM
var padding: float = 10.0
var span_extra: float = 10.0
var brace_depth: float = 22.0
var stroke_width: float = 3.0
var follow_target: bool = true
var minimum_span: float = 24.0

var _target_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(40.0, 20.0))


func _init(p_target_node: Node = null, p_side: BraceSide = BraceSide.BOTTOM) -> void:
	target_node = p_target_node
	side = p_side


func _ready() -> void:
	update_to_target()


func _process(delta: float) -> void:
	super._process(delta)
	if follow_target:
		update_to_target()


func set_target(node: Node) -> void:
	target_node = node
	update_to_target()


func update_to_target() -> void:
	if target_node == null or not is_instance_valid(target_node):
		return
	_target_rect = _compute_target_rect(target_node)

	var center := _target_rect.get_center()
	match side:
		BraceSide.TOP:
			global_position = Vector2(center.x, _target_rect.position.y - padding)
		BraceSide.BOTTOM:
			global_position = Vector2(center.x, _target_rect.end.y + padding)
		BraceSide.LEFT:
			global_position = Vector2(_target_rect.position.x - padding, center.y)
		BraceSide.RIGHT:
			global_position = Vector2(_target_rect.end.x + padding, center.y)
	queue_redraw()


func get_label_anchor(distance: float = 22.0) -> Vector2:
	match side:
		BraceSide.TOP:
			return global_position + Vector2(0.0, -brace_depth - distance)
		BraceSide.BOTTOM:
			return global_position + Vector2(0.0, brace_depth + distance)
		BraceSide.LEFT:
			return global_position + Vector2(-brace_depth - distance, 0.0)
		BraceSide.RIGHT:
			return global_position + Vector2(brace_depth + distance, 0.0)
	return global_position


func _draw() -> void:
	var points := _build_local_points()
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, stroke_width)


func _build_local_points() -> PackedVector2Array:
	match side:
		BraceSide.TOP:
			return _build_horizontal_points(_current_span_x(), -1.0)
		BraceSide.BOTTOM:
			return _build_horizontal_points(_current_span_x(), 1.0)
		BraceSide.LEFT:
			return _build_vertical_points(_current_span_y(), -1.0)
		BraceSide.RIGHT:
			return _build_vertical_points(_current_span_y(), 1.0)
	return PackedVector2Array()


func _current_span_x() -> float:
	return maxf(minimum_span, _target_rect.size.x + span_extra * 2.0)


func _current_span_y() -> float:
	return maxf(minimum_span, _target_rect.size.y + span_extra * 2.0)


func _build_horizontal_points(span: float, dir: float) -> PackedVector2Array:
	var h := span * 0.5
	var d := brace_depth * dir
	return PackedVector2Array([
		Vector2(-h, 0.0),
		Vector2(-h * 0.82, 0.0),
		Vector2(-h * 0.62, d * 0.55),
		Vector2(-h * 0.38, d),
		Vector2(-h * 0.14, d * 0.4),
		Vector2(0.0, 0.0),
		Vector2(h * 0.14, d * 0.4),
		Vector2(h * 0.38, d),
		Vector2(h * 0.62, d * 0.55),
		Vector2(h * 0.82, 0.0),
		Vector2(h, 0.0),
	])


func _build_vertical_points(span: float, dir: float) -> PackedVector2Array:
	var h := span * 0.5
	var d := brace_depth * dir
	return PackedVector2Array([
		Vector2(0.0, -h),
		Vector2(0.0, -h * 0.82),
		Vector2(d * 0.55, -h * 0.62),
		Vector2(d, -h * 0.38),
		Vector2(d * 0.4, -h * 0.14),
		Vector2(0.0, 0.0),
		Vector2(d * 0.4, h * 0.14),
		Vector2(d, h * 0.38),
		Vector2(d * 0.55, h * 0.62),
		Vector2(0.0, h * 0.82),
		Vector2(0.0, h),
	])


func _compute_target_rect(node: Node) -> Rect2:
	if node is PortTextMobject:
		var text_node := node as PortTextMobject
		var local_bounds := text_node.get_string_bounds()
		var top_left: Vector2 = text_node.to_global(local_bounds.position)
		return Rect2(top_left, local_bounds.size)
	if node is Label:
		var label := node as Label
		var global_rect := label.get_global_rect()
		return Rect2(global_rect.position, global_rect.size)
	if node is Rectangle:
		var rect_node := node as Rectangle
		var world_size := rect_node.size * rect_node.global_scale.abs()
		return Rect2(rect_node.global_position - world_size * 0.5, world_size)
	if node is Circle:
		var circle := node as Circle
		var radius := (circle.size.x * 0.5) * circle.global_scale.x
		var world_size := Vector2.ONE * absf(radius) * 2.0
		return Rect2(circle.global_position - world_size * 0.5, world_size)
	if node is Node2D:
		var node2d := node as Node2D
		return Rect2(node2d.global_position - Vector2(20.0, 20.0), Vector2(40.0, 40.0))
	return Rect2(Vector2.ZERO, Vector2(40.0, 40.0))
