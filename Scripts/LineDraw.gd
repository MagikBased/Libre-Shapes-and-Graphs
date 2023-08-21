class_name LineDraw
extends Node

enum LineType { LINEAR, CUBIC }

var duration : float = 2.0
var elapsed_line = 0.0
var start_point : Vector2
var end_point : Vector2

var target: Node2D

func set_target(value):
	target = value
	start_point = target.start_point

func _ready():
	print(start_point)
	match target.line_type:
		LineType.LINEAR:
			target.linepoints = [start_point, start_point]
		LineType.CUBIC:
			target.linepoints = [start_point]

func _process(delta):
	if elapsed_line <= duration:
		elapsed_line += delta
		var t = clamp(elapsed_line / duration,0,1)
		var new_point = start_point.lerp(target.end_point, t)
		target.linepoints[1] = new_point
		
#		match line_type:
#			LineType.LINEAR:
#				var new_point = start_point.lerp(end_point, t)
#				self.linepoints[1] = new_point
#			LineType.CUBIC:
#				var new_point = cubic_bezier(t, start_point, control_point_1, control_point_2, end_point)
#				self.linepoints.append(new_point)

