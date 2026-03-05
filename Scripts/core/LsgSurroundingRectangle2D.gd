class_name LsgSurroundingRectangle2D
extends Rectangle

var target_node: Node
var padding: Vector2 = Vector2(16.0, 12.0)
var follow_target: bool = true
var minimum_size: Vector2 = Vector2(8.0, 8.0)


func _init(p_target_node: Node = null, p_padding: Vector2 = Vector2(16.0, 12.0)) -> void:
	target_node = p_target_node
	padding = p_padding
	color = Color(0.7, 0.9, 1.0, 0.22)


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

	var rect := _compute_target_rect(target_node)
	size = Vector2(
		maxf(minimum_size.x, rect.size.x + padding.x * 2.0),
		maxf(minimum_size.y, rect.size.y + padding.y * 2.0)
	)
	global_position = rect.get_center()


func _compute_target_rect(node: Node) -> Rect2:
	if node is LsgTextMobject:
		var text_node := node as LsgTextMobject
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
