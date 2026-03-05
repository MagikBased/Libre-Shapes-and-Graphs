# Demo: CameraFramingDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var axes: GraphAxes2D
var plot: FunctionPlot2D
var dot: Circle
var x_tracker: LsgValueTracker


func _ready() -> void:
	_create_caption("Camera framing demo: move_camera + zoom_to_fit on graph content")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 96.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = -6.0
	axes.x_max = 9.0
	axes.y_min = -4.0
	axes.y_max = 4.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	plot = FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = &"sin"
	plot.sample_count = 260
	plot.stroke_width = 3.0
	plot.color = Color.DEEP_SKY_BLUE
	plot.position = axes.position
	plot.set_draw_progress(0.0)
	add_child(plot)

	dot = Circle.new()
	dot.size = Vector2(20.0, 20.0)
	dot.color = Color.ORANGE_RED
	dot.position = axes.to_global(axes.c2p(-5.0, sin(-5.0)))
	add_child(dot)

	x_tracker = GShapes.ValueTracker.new(-5.0)
	add_child(x_tracker)
	dot.add_updater(_update_dot)

	var axes_rect := Rect2(axes.to_global(Vector2.ZERO), axes.viewport_size)

	play(GShapes.ShowCreation.new(plot, 1.2, &"smooth"))
	play(GShapes.FadeIn.new(dot, 0.35, &"smooth"))
	wait(0.2)
	zoom_to_fit([axes_rect], 0.08, 1.0, &"smooth")
	wait(0.2)
	play(GShapes.SetValue.new(x_tracker, 7.5, 1.8, &"smooth"))
	wait(0.2)
	zoom_to_fit([dot.global_position], 0.45, 0.9, &"smooth")
	wait(0.2)
	move_camera(axes_rect.get_center(), 0.9, &"smooth")
	zoom_camera(Vector2.ONE, 0.9, &"smooth")


func _update_dot(target: LsgObject2D, _delta: float) -> void:
	var x := x_tracker.get_value()
	target.position = axes.to_global(axes.c2p(x, sin(x)))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
