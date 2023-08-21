class_name MotionController
extends Node


var target: Node2D

var current_t_index = 0
var position_easing = "Linear"
var color_easing = "Linear"

var start_position: Vector2
var end_position: Vector2
var lerp_duration: float = 2.0
var position_elapsed: float = 0.0
var color_elapsed: float = 0.0
var is_lerping: bool = false
var is_lerping_color: bool = false

var cubic_control_points = []

var reverse_position: bool = false
var reverse_color: bool = false
var loop: bool = false

var start_color: Color
var end_color: Color
var rainbow_colors = [Color(1, 0, 0), Color(1, 0.5, 0), Color(1, 1, 0), Color(0, 1, 0), Color(0, 0, 1), Color(0.5, 0, 1), Color(1, 0, 1)]

func set_target(value):
	target = value
	start_position = target.position

func apply_easing(t:float, easingType: String):
	match easingType:
		"Linear":
			return t
		"CubicIn":
			return t**3
		"CubicOut":
			return 1-((1-t)**3)
		"CubicInOut":
			return 4*(t**3)*(1- round(t)) + (1-4*((1-t)**3))*round(t)

func start_lerp_to(end_pos: Vector2, easing: String = "Linear", should_reverse: bool = false, should_loop:bool = false):
	end_position = end_pos
	position_elapsed = 0
	is_lerping = true
	position_easing = easing
	reverse_position = should_reverse
	loop = should_loop
	
func start_cubic_lerp(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2):
	cubic_control_points = [p0, p1, p2, p3]
	position_elapsed = 0
	is_lerping = true
	
func cubic_lerp(t: float, points: Array) -> Vector2:
	var a = (1 - t) * (1 - t) * (1 - t)
	var b = 3 * (1 - t) * (1 - t) * t
	var c = 3 * (1 - t) * t * t
	var d = t * t * t
	return a * points[0] + b * points[1] + c * points[2] + d * points[3]

func start_color_lerp(start_col:Color, end_col: Color, easing: String = "Linear", should_reverse: bool = false, should_loop:bool = false):
	start_color = start_col
	end_color = end_col
	color_elapsed = 0
	is_lerping_color = true
	color_easing = easing
	reverse_color = should_reverse
	loop = should_loop
	
func start_rainbow_lerp():
	start_color = rainbow_colors[0]
	current_t_index = 0
	end_color = rainbow_colors[1]
	color_elapsed = 0
	is_lerping_color = true

func color_interpolate(t: float, start_col: Color, end_col: Color) -> Color:
	var r = start_col.r + t * (end_col.r - start_col.r)
	var g = start_col.g + t * (end_col.g - start_col.g)
	var b = start_col.b + t * (end_col.b - start_col.b)
	var a = start_col.a + t * (end_col.a - start_col.a)
	return Color(r, g, b, a)

func _process(delta):
	if is_lerping:
		position_elapsed += delta if reverse_position else -delta
		var raw_t_position = clamp(position_elapsed / lerp_duration, 0, 1)
		var t_position = apply_easing(raw_t_position,position_easing)
		#print(t_position)
		if cubic_control_points.size() == 4:
			target.position = cubic_lerp(t_position,cubic_control_points)
		else:
			target.position = start_position.lerp(end_position, t_position)
		if t_position == 1 or t_position == 0:
			reverse_position = !reverse_position
			if !(loop):
				is_lerping = false
			cubic_control_points.clear()
		
	if is_lerping_color:
		color_elapsed += delta if reverse_color else -delta
		var raw_t_color = clamp(color_elapsed / lerp_duration,0,1)
		var t_color = apply_easing(raw_t_color,color_easing)
		var did_toggle = false
		target.modulate = color_interpolate(t_color,start_color,end_color)
		if (t_color == 1 or t_color ==0) and !did_toggle:
			reverse_color = !reverse_color
			did_toggle = true
		else:
			did_toggle = false
		if !(loop):
			is_lerping_color = false
			#start_color = rainbow_colors[current_t_index]
			#current_t_index = (current_t_index+1) % rainbow_colors.size()
			#end_color = rainbow_colors[current_t_index]
			color_elapsed = 0
