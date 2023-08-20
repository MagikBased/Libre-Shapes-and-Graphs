extends Node2D

var spawner = Spawner.new()
var circle1 = spawner.spawn_shape("Circle", Vector2(150, 150))

func _ready():
	add_child(spawner)
	

func _process(_delta):
	pass

func _draw():
	pass
