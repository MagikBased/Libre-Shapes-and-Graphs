class_name GShapesFlashAround
extends GShapesAnimation

var stroke_color: Color = Color.YELLOW
var stroke_width: float = 3.0
var padding: float = 8.0

var _flash_line: Line2D


func _init(
	p_target: Node2D,
	p_run_time: float = 0.6,
	p_rate_func_name: StringName = &"there_and_back",
	p_stroke_color: Color = Color.YELLOW,
	p_stroke_width: float = 3.0,
	p_padding: float = 8.0
) -> void:
	stroke_color = p_stroke_color
	stroke_width = maxf(1.0, p_stroke_width)
	padding = maxf(0.0, p_padding)
	super(p_target, p_run_time, p_rate_func_name)


func on_begin() -> void:
	if target == null or target.get_parent() == null:
		return

	var rect := _estimate_target_rect(target)
	var p := rect.position - Vector2(padding, padding)
	var s := rect.size + Vector2(padding * 2.0, padding * 2.0)
	_flash_line = Line2D.new()
	_flash_line.width = stroke_width
	_flash_line.default_color = Color(stroke_color.r, stroke_color.g, stroke_color.b, 0.0)
	_flash_line.closed = true
	_flash_line.points = PackedVector2Array([
		p,
		p + Vector2(s.x, 0.0),
		p + s,
		p + Vector2(0.0, s.y),
	])
	target.get_parent().add_child(_flash_line)


func interpolate(alpha: float) -> void:
	if _flash_line == null:
		return
	var c := _flash_line.default_color
	c.a = 0.9 * clampf(alpha, 0.0, 1.0)
	_flash_line.default_color = c


func on_finish() -> void:
	if _flash_line != null:
		_flash_line.queue_free()
		_flash_line = null


func _estimate_target_rect(node: Node2D) -> Rect2:
	if node is GShapesTextMobject:
		var ptxt := node as GShapesTextMobject
		var local := ptxt.get_string_bounds()
		return Rect2(node.position + local.position, local.size)
	if node is Circle:
		var c := node as Circle
		var r := c.size.x * 0.5
		return Rect2(node.position - Vector2(r, r), Vector2(r * 2.0, r * 2.0))
	if node is Rectangle:
		var rr := node as Rectangle
		return Rect2(node.position - rr.size * 0.5, rr.size)
	return Rect2(node.position - Vector2(24.0, 24.0), Vector2(48.0, 48.0))




