class_name Line
extends PortObject2D

enum LineType { LINEAR, CUBIC }

var start_point : Vector2
var end_point : Vector2
var temp_end_point: Vector2 #= start_point
var linepoints:PackedVector2Array = []
var control_point_1 : Vector2
var control_point_2 : Vector2
var line_type : LineType = LineType.LINEAR
var stroke_width: float = 5.0
var curve_samples: int = 48

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
	set_draw_progress(1.0)


func set_draw_progress(progress: float) -> void:
	var t := clampf(progress, 0.0, 1.0)
	match line_type:
		LineType.LINEAR:
			var new_point := start_point.lerp(end_point, t)
			linepoints = PackedVector2Array([start_point, new_point])
		LineType.CUBIC:
			if is_zero_approx(t):
				linepoints = PackedVector2Array([start_point, start_point])
				queue_redraw()
				return
			var target_count := maxi(2, int(ceil(float(curve_samples) * t)))
			linepoints.clear()
			for i in range(target_count + 1):
				var tt := (float(i) / float(target_count)) * t
				linepoints.append(cubic_bezier(tt, start_point, control_point_1, control_point_2, end_point))
	queue_redraw()


func set_endpoints(new_start: Vector2, new_end: Vector2) -> void:
	start_point = new_start
	end_point = new_end
	linepoints = PackedVector2Array([start_point, end_point])
	queue_redraw()
	
func _process(_delta):
	super._process(_delta)
	queue_redraw()

func _draw():
	if linepoints.size() < 2:
		return
	for i in range(linepoints.size() - 1):
		draw_line(linepoints[i], linepoints[i + 1], color, stroke_width)
