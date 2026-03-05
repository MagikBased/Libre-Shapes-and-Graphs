# Demo: SecantSlopeGroupParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var plot: FunctionPlot2D
var secant_group: GShapesSecantSlopeGroup2D
var x_tracker: GShapesValueTracker
var dx_tracker: GShapesValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 secant-slope-group parity: dynamic secant with dx/dy and slope labels")

	axes = GraphAxes2D.new()
	axes.position = Vector2(110.0, 92.0)
	axes.viewport_size = Vector2(1010.0, 560.0)
	axes.x_min = -4.0
	axes.x_max = 7.5
	axes.y_min = -4.5
	axes.y_max = 5.5
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	plot = FunctionPlot2D.new()
	plot.axes = axes
	plot.function_name = &"cubic"
	plot.render_mode = &"smooth"
	plot.sample_count = 280
	plot.color = Color(0.34, 0.84, 1.0, 0.9)
	plot.stroke_width = 2.9
	plot.position = axes.position
	add_child(plot)

	x_tracker = GShapes.ValueTracker.new(-2.6)
	dx_tracker = GShapes.ValueTracker.new(1.5)
	add_child(x_tracker)
	add_child(dx_tracker)

	secant_group = GShapes.SecantSlopeGroup2D.new()
	secant_group.axes = axes
	secant_group.graph = plot
	secant_group.position = axes.position
	secant_group.x_value = x_tracker.get_value()
	secant_group.delta_x = dx_tracker.get_value()
	add_child(secant_group)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(plot, 1.1, &"smooth"))
	play(GShapes.FadeIn.new(secant_group, 0.35, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x_tracker, 5.2, 1.7, &"smooth"),
		GShapes.SetValue.new(dx_tracker, 0.25, 1.25, &"smooth"),
		GShapes.SetValue.new(x_tracker, -0.5, 1.2, &"there_and_back_with_pause"),
		GShapes.SetValue.new(dx_tracker, 1.3, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if secant_group == null or x_tracker == null or dx_tracker == null:
		return
	secant_group.x_value = x_tracker.get_value()
	secant_group.delta_x = dx_tracker.get_value()
	secant_group.rebuild()
	info_label.text = "x=%.2f  dx=%.2f  secant_slope=%.3f" % [
		secant_group.x_value,
		secant_group.delta_x,
		secant_group.slope_value(),
	]


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




