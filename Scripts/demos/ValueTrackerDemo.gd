# Demo: ValueTrackerDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var parabola: FunctionPlot2D
var dot: Circle
var x_tracker: GShapesValueTracker


func _ready() -> void:
	_create_caption("Value tracker demo: animate x and update point on parabola")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 120.0)
	axes.viewport_size = Vector2(980.0, 520.0)
	axes.x_min = -3.0
	axes.x_max = 10.0
	axes.y_min = -1.0
	axes.y_max = 8.0
	add_child(axes)

	parabola = FunctionPlot2D.new()
	parabola.axes = axes
	parabola.function_name = &"parabola"
	parabola.sample_count = 220
	parabola.color = Color.ORANGE_RED
	parabola.stroke_width = 3.0
	parabola.position = axes.position
	add_child(parabola)
	parabola.set_draw_progress(0.0)

	x_tracker = GShapes.ValueTracker.new(2.0)
	add_child(x_tracker)

	dot = Circle.new()
	dot.size = Vector2(20.0, 20.0)
	dot.color = Color.RED
	add_child(dot)
	dot.add_updater(_update_dot_position)

	play(GShapes.ShowCreation.new(parabola, 1.2, &"smooth"))
	wait_seconds(0.2)
	play(GShapes.FadeIn.new(dot, 0.3, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x_tracker, 4.0, 1.8, &"smooth"),
		GShapes.SetValue.new(x_tracker, -2.0, 1.8, &"smooth"),
	])


func _update_dot_position(target: GShapesObject2D, _delta: float) -> void:
	var x := x_tracker.get_value()
	var y := parabola.eval_y(x)
	target.position = axes.position + axes.graph_to_local(Vector2(x, y))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)



