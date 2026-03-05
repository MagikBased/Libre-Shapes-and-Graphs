# Demo: GraphDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene
var axes: GraphAxes2D
var plot: FunctionPlot2D


func _ready() -> void:
	_create_caption("Graph demo: sampled function plot with creation animation")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 100.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 6.0
	axes.y_min = -3.5
	axes.y_max = 3.5
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	plot = FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = &"sin"
	plot.sample_count = 240
	plot.color = Color.ORANGE_RED
	plot.stroke_width = 3.0
	plot.position = axes.position
	add_child(plot)
	plot.set_draw_progress(0.0)

	play(GShapes.ShowCreation.new(plot, 2.3, &"smooth"))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



