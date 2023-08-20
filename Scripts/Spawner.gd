class_name Spawner
extends Node2D

func spawn_shape(shape_type: String, pos: Vector2, color: Color):
	var shape = load("res://Scripts/" + shape_type + ".gd").new()
	shape.position = pos
	shape.color = color
	add_child(shape)
	return shape

func spawn_graph(graph_type: String, pos: Vector2, data_points):
	var graph = load("res://Scripts/" + graph_type + ".gd").new()
	graph.position = pos
	graph.data_points = data_points
	add_child(graph)
	return graph
