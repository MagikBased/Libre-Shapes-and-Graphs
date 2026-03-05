# Demo: ExampleGraphSceneDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var axes: GraphAxes2D
var active_plot: FunctionPlot2D
var dot: Circle


func _ready() -> void:
	_create_caption("GraphExample adaptation: graph creation, replacement, and point motion")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 120.0)
	axes.viewport_size = Vector2(980.0, 520.0)
	axes.x_min = -3.0
	axes.x_max = 10.0
	axes.y_min = -1.0
	axes.y_max = 8.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	active_plot = _make_plot(&"sin", Color.DEEP_SKY_BLUE)
	play(GShapes.ShowCreation.new(active_plot, 1.2, &"smooth"))
	wait_seconds(1.0)

	var parabola := _make_plot(&"parabola", Color.ORANGE_RED)
	play(GShapes.FadeOut.new(active_plot, 0.6, &"smooth"))
	play(GShapes.FadeIn.new(parabola, 0.6, &"smooth"))
	wait_seconds(0.5)
	active_plot = parabola

	dot = Circle.new()
	dot.size = Vector2(20.0, 20.0)
	dot.color = Color.RED
	add_child(dot)
	_set_dot_to_parabola_x(2.0)
	play(GShapes.FadeIn.new(dot, 0.4, &"smooth"))
	wait_seconds(0.2)

	play(GShapes.MoveTo.new(dot, _parabola_world_point(4.0), 1.8, &"smooth"))
	wait_seconds(0.1)
	play(GShapes.MoveTo.new(dot, _parabola_world_point(-2.0), 1.8, &"smooth"))


func _make_plot(function_name: StringName, plot_color: Color) -> FunctionPlot2D:
	var plot := FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = function_name
	plot.sample_count = 220
	plot.color = plot_color
	plot.stroke_width = 3.0
	plot.position = axes.position
	add_child(plot)
	if function_name == &"parabola":
		plot.modulate.a = 0.0
	return plot


func _parabola_world_point(x: float) -> Vector2:
	var y := 0.25 * x * x
	return axes.position + axes.graph_to_local(Vector2(x, y))


func _set_dot_to_parabola_x(x: float) -> void:
	dot.position = _parabola_world_point(x)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
