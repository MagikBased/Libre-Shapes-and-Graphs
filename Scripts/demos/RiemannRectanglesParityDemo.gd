# Demo: RiemannRectanglesParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var plot: FunctionPlot2D
var rectangles: GShapesRiemannRectangles2D
var x_tracker: GShapesValueTracker
var dx_tracker: GShapesValueTracker
var mode_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 Riemann rectangles parity: left/right/midpoint area approximation")

	axes = GraphAxes2D.new()
	axes.position = Vector2(100.0, 92.0)
	axes.viewport_size = Vector2(1020.0, 560.0)
	axes.x_min = -4.0
	axes.x_max = 8.0
	axes.y_min = -4.0
	axes.y_max = 7.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	plot = FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = &"cubic"
	plot.render_mode = &"smooth"
	plot.sample_count = 260
	plot.color = Color(0.58, 0.86, 1.0, 0.9)
	plot.stroke_width = 2.8
	plot.position = axes.position
	add_child(plot)

	rectangles = GShapes.RiemannRectangles2D.new()
	rectangles.axes = axes
	rectangles.graph = plot
	rectangles.position = axes.position
	rectangles.x_min_value = -2.8
	rectangles.x_max_value = 3.2
	rectangles.baseline_y = 0.0
	rectangles.delta_x = 1.0
	rectangles.sample_mode = &"left"
	rectangles.color = Color(0.95, 0.98, 1.0, 0.88)
	rectangles.recompute_rectangles()
	add_child(rectangles)

	x_tracker = GShapes.ValueTracker.new(3.2)
	dx_tracker = GShapes.ValueTracker.new(1.0)
	mode_tracker = GShapes.ValueTracker.new(0.0)
	add_child(x_tracker)
	add_child(dx_tracker)
	add_child(mode_tracker)

	rectangles.add_updater(_update_rectangles)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(plot, 1.0, &"smooth"))
	play(GShapes.FadeIn.new(rectangles, 0.55, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x_tracker, 5.8, 1.3, &"smooth"),
		GShapes.SetValue.new(dx_tracker, 0.25, 1.45, &"smooth"),
		GShapes.SetValue.new(mode_tracker, 1.0, 0.8, &"smooth"),
		GShapes.SetValue.new(mode_tracker, 2.0, 0.8, &"smooth"),
		GShapes.SetValue.new(x_tracker, 2.2, 1.0, &"there_and_back_with_pause"),
	])


func _update_rectangles(_target: GShapesObject2D, _delta: float) -> void:
	var right: float = x_tracker.get_value()
	var dx: float = dx_tracker.get_value()
	var mode_value: float = mode_tracker.get_value()
	var mode_index: int = clampi(int(round(mode_value)), 0, 2)
	var mode_name: StringName = &"left"
	if mode_index == 1:
		mode_name = &"right"
	elif mode_index == 2:
		mode_name = &"midpoint"

	rectangles.x_max_value = right
	rectangles.delta_x = maxf(0.08, dx)
	rectangles.sample_mode = mode_name
	rectangles.recompute_rectangles()
	info_label.text = "mode=%s  dx=%.2f  interval=[%.2f, %.2f]" % [String(mode_name), rectangles.delta_x, rectangles.x_min_value, right]


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




