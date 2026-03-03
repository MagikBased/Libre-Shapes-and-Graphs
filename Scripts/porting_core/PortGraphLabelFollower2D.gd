class_name PortGraphLabelFollower2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var label_node: Label
var text: String = "f(x)"
var font_size: int = 18
var text_color: Color = Color.WHITE
var x_value: float = 0.0
var x_callable: Callable
var anchor: StringName = &"auto"
var tangent_offset: float = 0.0
var normal_offset: float = -18.0
var clamp_inside_axes: bool = true


func _ready() -> void:
	_ensure_label()
	_update_label_transform()


func _process(_delta: float) -> void:
	_update_label_transform()


func _ensure_label() -> void:
	if label_node == null:
		label_node = Label.new()
		add_child(label_node)
	label_node.text = text
	label_node.modulate = text_color
	label_node.add_theme_font_size_override("font_size", font_size)


func _sample_x() -> float:
	if x_callable.is_valid():
		var v: Variant = x_callable.call()
		if v is float or v is int:
			return float(v)
	return x_value


func _update_label_transform() -> void:
	if axes == null or graph == null:
		return
	_ensure_label()

	var x: float = _sample_x()
	var y: float = graph.eval_y(x)
	var point_local: Vector2 = axes.c2p(x, y)

	var slope: float = graph.get_slope_at_x(x)
	var tangent: Vector2 = Vector2(1.0, slope).normalized()
	var normal: Vector2 = Vector2(-tangent.y, tangent.x)
	var target_local: Vector2 = point_local + tangent * tangent_offset + normal * normal_offset
	var target_world: Vector2 = axes.to_global(target_local)

	var size: Vector2 = label_node.get_minimum_size()
	var top_left_world: Vector2 = _compute_anchor_top_left(target_world, size)
	if clamp_inside_axes:
		top_left_world = _clamp_world_top_left(top_left_world, size)

	label_node.global_position = top_left_world


func _compute_anchor_top_left(point_world: Vector2, size: Vector2) -> Vector2:
	var margin: Vector2 = Vector2(8.0, 6.0)
	match String(anchor).to_lower():
		"right":
			return point_world + Vector2(margin.x, -0.5 * size.y)
		"left":
			return point_world + Vector2(-size.x - margin.x, -0.5 * size.y)
		"up":
			return point_world + Vector2(-0.5 * size.x, -size.y - margin.y)
		"down":
			return point_world + Vector2(-0.5 * size.x, margin.y)
		_:
			return point_world + Vector2(margin.x, -size.y - margin.y)


func _clamp_world_top_left(world_pos: Vector2, size: Vector2) -> Vector2:
	var viewport_world_origin: Vector2 = axes.to_global(Vector2.ZERO)
	var min_x: float = viewport_world_origin.x
	var min_y: float = viewport_world_origin.y
	var max_x: float = viewport_world_origin.x + axes.viewport_size.x - size.x
	var max_y: float = viewport_world_origin.y + axes.viewport_size.y - size.y
	return Vector2(
		clampf(world_pos.x, min_x, max_x),
		clampf(world_pos.y, min_y, max_y)
	)
