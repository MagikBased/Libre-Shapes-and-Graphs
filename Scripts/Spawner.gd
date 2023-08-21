class_name Spawner
extends Node2D

func spawn_shape(shape_type: String, pos: Vector2, color: Color):
	var shape = load("res://Scripts/" + shape_type + ".gd").new()
	shape.position = pos
	shape.color = color
	add_child(shape)
	return shape

func spawn_line(_start_point: Vector2, _end_point: Vector2):
	var line = load("res://Scripts/Line.gd").new()
	line.start_point = _start_point
	line.end_point = _end_point
	#line.position = pos
	add_child(line)
	print("Line: "+str(line))
	return line

func spawn_graph(graph_type: String, pos: Vector2, data_points):
	var graph = load("res://Scripts/" + graph_type + ".gd").new()
	graph.position = pos
	graph.data_points = data_points
	add_child(graph)
	return graph
