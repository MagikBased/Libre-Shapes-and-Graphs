class_name PortGraphGuideLines2D
extends PortObject2D

var axes: GraphAxes2D
var graph_point: Vector2 = Vector2.ZERO
var show_horizontal: bool = true
var show_vertical: bool = true
var stroke_width: float = 2.0
var draw_progress: float = 1.0


func set_graph_point(point: Vector2) -> void:
	graph_point = point
	queue_redraw()


func set_draw_progress(progress: float) -> void:
	draw_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if axes == null:
		return
	var p := axes.c2p(graph_point.x, graph_point.y)
	var t := clampf(draw_progress, 0.0, 1.0)

	if show_horizontal:
		var a := axes.c2p(axes.x_min, graph_point.y)
		var b := p
		var end := a.lerp(b, t)
		draw_line(a, end, color, stroke_width)

	if show_vertical:
		var c := axes.c2p(graph_point.x, axes.y_min)
		var d := p
		var vend := c.lerp(d, t)
		draw_line(c, vend, color, stroke_width)
