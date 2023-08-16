extends Node2D

var spawner = Spawner.new()

func _ready():
	add_child(spawner)
	spawner.spawn_shape("Circle", Vector2(100, 100))
