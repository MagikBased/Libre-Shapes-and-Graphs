class_name Rectangle
extends Shape

func _draw():
	var rect := Rect2(-size * 0.5, size)
	draw_rect(rect, color, true)

