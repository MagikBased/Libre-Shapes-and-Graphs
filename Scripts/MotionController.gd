extends Node

var target: Node2D = null :set = set_target, get = get_target

# Lerp properties
var start_position: Vector2
var end_position: Vector2
var lerp_duration: float = 2.0
var lerp_elapsed: float = 0.0
var is_lerping: bool = false

func set_target(value):
	target = value
	start_position = target.position

func get_target():
	pass

func start_lerp_to(end_pos: Vector2):
	end_position = end_pos
	lerp_elapsed = 0
	is_lerping = true

func _process(delta):
	if is_lerping:
		lerp_elapsed += delta
		var t = clamp(lerp_elapsed / lerp_duration, 0, 1)
		target.position = start_position.lerp(end_position, t)
		
		if t == 1:
			is_lerping = false
