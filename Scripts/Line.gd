class_name Line
extends Node2D

enum LineType { LINEAR, CUBIC }

var start_point : Vector2
var end_point : Vector2
var temp_end_point: Vector2 #= start_point
var linepoints:PackedVector2Array = []
var control_point_1 : Vector2
var control_point_2 : Vector2
var line_type : LineType = LineType.LINEAR

var test = [Vector2(800,450)]

func cubic_bezier(t, p0, p1, p2, p3):
	var u = 1 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	var p = uuu * p0
	p += 3 * uu * t * p1
	p += 3 * u * tt * p2
	p += ttt * p3
	return p

func _ready():
	pass
	
func _process(_delta):
	queue_redraw()

func _draw():
	draw_line(Vector2(linepoints[0]),Vector2(linepoints[1]),Color.WHITE,5)
#	if linepoints.size() > 1:
#		for i in range(linepoints.size()-1):
#			print(i)
#			draw_line(linepoints[i],linepoints[i+1],Color.WHITE,1)
#			print(linepoints[i],linepoints[i+1])
	#else:
		#draw_line(start_point,end_point,Color.WHITE,1)
	#draw_line(start_point,temp_end_point,Color.WHITE,1,true)
