# Demo: ImplicitFunctionDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene
var axes: GraphAxes2D
var implicit_graph: ImplicitFunction2D


func _ready() -> void:
	_create_caption("Implicit function demo: marching-squares contour rendering")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 100.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = -3.0
	axes.x_max = 3.0
	axes.y_min = -3.0
	axes.y_max = 3.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	implicit_graph = ImplicitFunction2D.new()
	implicit_graph.axes = axes
	implicit_graph.function_name = &"lemniscate"
	implicit_graph.grid_resolution = 96
	implicit_graph.color = Color.ORANGE_RED
	implicit_graph.stroke_width = 2.0
	implicit_graph.position = axes.position
	add_child(implicit_graph)
	implicit_graph.set_draw_progress(0.0)

	play(GShapes.ShowCreation.new(implicit_graph, 2.0, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



