# Demo: UpdaterGraphDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var parabola: FunctionPlot2D
var dot: Circle
var x_controller: Node2D


func _ready() -> void:
	_create_caption("Updater graph demo: dot tracks parabola via add_updater")

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

	x_controller = Node2D.new()
	x_controller.position = Vector2(2.0, 0.0)
	add_child(x_controller)

	dot = Circle.new()
	dot.size = Vector2(20.0, 20.0)
	dot.color = Color.RED
	add_child(dot)
	dot.add_updater(_update_dot_position)

	play(PortShowCreation.new(parabola, 1.4, &"smooth"))
	wait_seconds(0.2)
	play(PortFadeIn.new(dot, 0.3, &"smooth"))
	play_sequence([
		PortMoveTo.new(x_controller, Vector2(4.0, 0.0), 2.0, &"smooth"),
		PortMoveTo.new(x_controller, Vector2(-2.0, 0.0), 2.0, &"smooth"),
	])


func _update_dot_position(target: PortObject2D, _delta: float) -> void:
	var x := x_controller.position.x
	var y := parabola.eval_y(x)
	target.position = axes.position + axes.graph_to_local(Vector2(x, y))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
