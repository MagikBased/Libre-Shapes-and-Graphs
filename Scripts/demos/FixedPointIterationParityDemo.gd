# Demo: FixedPointIterationParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var iter_helper: LsgFixedPointIteration2D
var k_tracker: LsgValueTracker
var x0_tracker: LsgValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 fixed-point parity: cobweb iteration on dynamic map g(x)=cos(x)+k")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 82.0)
	axes.viewport_size = Vector2(980.0, 600.0)
	axes.x_min = -1.8
	axes.x_max = 2.2
	axes.y_min = -1.8
	axes.y_max = 2.2
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	k_tracker = GShapes.ValueTracker.new(0.05)
	x0_tracker = GShapes.ValueTracker.new(1.6)
	add_child(k_tracker)
	add_child(x0_tracker)

	iter_helper = GShapes.FixedPointIteration2D.new()
	iter_helper.axes = axes
	iter_helper.position = axes.position
	iter_helper.map_callable = Callable(self, "_map_value")
	iter_helper.initial_x = x0_tracker.get_value()
	iter_helper.iteration_count = 8
	iter_helper.auto_update = false
	add_child(iter_helper)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(iter_helper, 0.45, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x0_tracker, -0.9, 1.3, &"smooth"),
		GShapes.SetValue.new(k_tracker, -0.25, 1.25, &"there_and_back_with_pause"),
		GShapes.SetValue.new(x0_tracker, 0.5, 1.1, &"smooth"),
	])


func _process(_delta: float) -> void:
	if iter_helper == null:
		return
	iter_helper.initial_x = x0_tracker.get_value()
	iter_helper.rebuild()
	info_label.text = "k=%.2f  x0=%.2f  fixed_point_est=%.4f" % [
		k_tracker.get_value(),
		x0_tracker.get_value(),
		iter_helper.current_estimate(),
	]


func _map_value(x: float) -> float:
	return cos(x) + k_tracker.get_value()


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

