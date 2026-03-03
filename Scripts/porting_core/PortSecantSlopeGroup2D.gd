class_name PortSecantSlopeGroup2D
extends Node2D

var axes: GraphAxes2D
var graph: FunctionPlot2D
var x_value: float = 0.0
var delta_x: float = 1.0
var secant_color: Color = Color(1.0, 0.78, 0.36, 0.95)
var dx_color: Color = Color(0.36, 0.88, 1.0, 0.95)
var dy_color: Color = Color(1.0, 0.45, 0.45, 0.95)
var line_width: float = 2.1
var marker_radius: float = 4.0
var show_labels: bool = true
var auto_update: bool = true

var _p0: Vector2 = Vector2.ZERO
var _p1: Vector2 = Vector2.ZERO
var _dx_a: Vector2 = Vector2.ZERO
var _dx_b: Vector2 = Vector2.ZERO
var _dy_a: Vector2 = Vector2.ZERO
var _dy_b: Vector2 = Vector2.ZERO
var _valid: bool = false

var _dx_label: Label
var _dy_label: Label
var _m_label: Label


func _ready() -> void:
	_ensure_labels()
	rebuild()


func _process(_delta: float) -> void:
	if auto_update:
		rebuild()


func rebuild() -> void:
	_valid = false
	if axes == null or graph == null:
		_hide_labels()
		queue_redraw()
		return

	var x0: float = x_value
	var x1: float = x_value + delta_x
	var y0: float = graph.eval_y(x0)
	var y1: float = graph.eval_y(x1)

	_p0 = axes.c2p(x0, y0)
	_p1 = axes.c2p(x1, y1)
	_dx_a = axes.c2p(x0, y0)
	_dx_b = axes.c2p(x1, y0)
	_dy_a = axes.c2p(x1, y0)
	_dy_b = axes.c2p(x1, y1)

	_valid = true
	queue_redraw()
	_update_labels(x0, x1, y0, y1)


func slope_value() -> float:
	if absf(delta_x) <= 0.000001:
		return 0.0
	if graph == null:
		return 0.0
	var y0: float = graph.eval_y(x_value)
	var y1: float = graph.eval_y(x_value + delta_x)
	return (y1 - y0) / delta_x


func _ensure_labels() -> void:
	if _dx_label == null:
		_dx_label = Label.new()
		add_child(_dx_label)
	if _dy_label == null:
		_dy_label = Label.new()
		add_child(_dy_label)
	if _m_label == null:
		_m_label = Label.new()
		add_child(_m_label)

	_dx_label.add_theme_font_size_override("font_size", 14)
	_dy_label.add_theme_font_size_override("font_size", 14)
	_m_label.add_theme_font_size_override("font_size", 14)
	_dx_label.modulate = dx_color
	_dy_label.modulate = dy_color
	_m_label.modulate = secant_color


func _hide_labels() -> void:
	if _dx_label != null:
		_dx_label.visible = false
	if _dy_label != null:
		_dy_label.visible = false
	if _m_label != null:
		_m_label.visible = false


func _update_labels(x0: float, x1: float, y0: float, y1: float) -> void:
	_ensure_labels()
	if not show_labels or not _valid:
		_hide_labels()
		return

	var dx_value: float = x1 - x0
	var dy_value: float = y1 - y0
	var slope: float = 0.0
	if absf(dx_value) > 0.000001:
		slope = dy_value / dx_value

	_dx_label.visible = true
	_dy_label.visible = true
	_m_label.visible = true

	_dx_label.text = "dx=%.2f" % dx_value
	_dy_label.text = "dy=%.2f" % dy_value
	_m_label.text = "m=%.2f" % slope

	_dx_label.position = (_dx_a + _dx_b) * 0.5 + Vector2(-16.0, 8.0)
	_dy_label.position = (_dy_a + _dy_b) * 0.5 + Vector2(8.0, -8.0)
	_m_label.position = (_p0 + _p1) * 0.5 + Vector2(10.0, -18.0)


func _draw() -> void:
	if not _valid:
		return
	draw_line(_p0, _p1, secant_color, line_width)
	draw_line(_dx_a, _dx_b, dx_color, line_width)
	draw_line(_dy_a, _dy_b, dy_color, line_width)
	draw_circle(_p0, marker_radius, secant_color)
	draw_circle(_p1, marker_radius, secant_color)
