class_name Spawner
extends Node2D

func spawn_shape(shape_type: String, position: Vector2):
	var shape = load("res://Scripts/" + shape_type + ".gd").new()
	shape.position = position
	add_child(shape)

func spawn_graph(graph_type: String, position: Vector2, data_points):
	var graph = load("res://Scripts/" + graph_type + ".gd").new()
	graph.position = position
	graph.data_points = data_points
	add_child(graph)
