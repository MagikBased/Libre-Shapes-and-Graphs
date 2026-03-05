# Demo: AdvancedParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var axes: GraphAxes2D
var sin_plot: FunctionPlot2D
var step_plot: FunctionPlot2D
var sin_label: Label
var step_label: Label
var dot: Circle
var x_tracker: LsgValueTracker


func _ready() -> void:
	_create_caption("Advanced parity demo: labels, discontinuity, replacement transform, tracker")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 100.0)
	axes.viewport_size = Vector2(1000.0, 560.0)
	axes.x_min = -3.0
	axes.x_max = 10.0
	axes.y_min = -1.0
	axes.y_max = 8.0
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	sin_plot = FunctionPlot2D.new()
	sin_plot.axes = axes
	sin_plot.function_name = &"sin"
	sin_plot.sample_count = 260
	sin_plot.color = Color.DEEP_SKY_BLUE
	sin_plot.stroke_width = 3.0
	sin_plot.position = axes.position
	add_child(sin_plot)
	sin_plot.set_draw_progress(0.0)

	step_plot = FunctionPlot2D.new()
	step_plot.axes = axes
	step_plot.function_name = &"step"
	step_plot.sample_count = 260
	step_plot.discontinuities = PackedFloat32Array([3.0])
	step_plot.style = &"dashed"
	step_plot.color = Color.LIME_GREEN
	step_plot.stroke_width = 3.0
	step_plot.position = axes.position
	step_plot.modulate.a = 0.0
	add_child(step_plot)

	sin_label = axes.get_graph_label(sin_plot, "sin(x)", 7.0, 18, Color.DEEP_SKY_BLUE)
	sin_label.position += axes.position
	add_child(sin_label)

	step_label = axes.get_graph_label(step_plot, "step(x)", 4.2, 18, Color.LIME_GREEN)
	step_label.position += axes.position
	step_label.modulate.a = 0.0
	add_child(step_label)

	play(GShapes.ShowCreation.new(sin_plot, 1.3, &"smooth"))
	wait(0.4)
	play(GShapes.ReplacementTransform.new(sin_plot, step_plot, 0.8, &"smooth"))
	sin_label.modulate.a = 0.0
	step_label.modulate.a = 1.0
	wait(0.3)

	x_tracker = GShapes.ValueTracker.new(1.5)
	add_child(x_tracker)
	dot = Circle.new()
	dot.size = Vector2(18.0, 18.0)
	dot.color = Color.RED
	add_child(dot)
	dot.add_updater(_update_dot_on_step)
	play(GShapes.FadeIn.new(dot, 0.25, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x_tracker, 6.0, 1.2, &"wiggle"),
		GShapes.SetValue.new(x_tracker, 2.0, 1.2, &"there_and_back_with_pause"),
	])


func _update_dot_on_step(target: LsgObject2D, _delta: float) -> void:
	var x := x_tracker.get_value()
	var y := 2.0 if x > 3.0 else 1.0
	target.position = axes.to_global(axes.c2p(x, y))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
