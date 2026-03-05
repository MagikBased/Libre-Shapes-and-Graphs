# Demo: IterationSequenceParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var seq_plot: LsgIterationSequencePlot2D
var k_tracker: LsgValueTracker
var x0_tracker: LsgValueTracker
var end_marker: Circle
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 iteration-sequence parity: x_n trace for fixed-point map on iteration axis")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 92.0)
	axes.viewport_size = Vector2(940.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 12.0
	axes.y_min = -1.5
	axes.y_max = 2.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	k_tracker = GShapes.ValueTracker.new(0.05)
	x0_tracker = GShapes.ValueTracker.new(1.4)
	add_child(k_tracker)
	add_child(x0_tracker)

	seq_plot = GShapes.IterationSequencePlot2D.new()
	seq_plot.axes = axes
	seq_plot.position = axes.position
	seq_plot.initial_value = x0_tracker.get_value()
	seq_plot.iteration_count = 11
	seq_plot.stroke_width = 2.8
	seq_plot.color = Color(1.0, 0.76, 0.36, 0.95)
	seq_plot.map_callable = Callable(self, "_map_value")
	seq_plot.auto_update = false
	seq_plot.rebuild_sequence()
	seq_plot.set_draw_progress(0.0)
	add_child(seq_plot)

	end_marker = Circle.new()
	end_marker.size = Vector2(12.0, 12.0)
	end_marker.color = Color(0.4, 0.9, 1.0, 0.95)
	add_child(end_marker)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.ShowCreation.new(seq_plot, 1.1, &"smooth"))
	play(GShapes.FadeIn.new(end_marker, 0.35, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(x0_tracker, -0.8, 1.25, &"smooth"),
		GShapes.SetValue.new(k_tracker, -0.22, 1.35, &"there_and_back_with_pause"),
		GShapes.SetValue.new(x0_tracker, 0.6, 1.1, &"smooth"),
	])


func _process(_delta: float) -> void:
	if seq_plot == null:
		return
	seq_plot.initial_value = x0_tracker.get_value()
	seq_plot.rebuild_sequence()
	var values: Array[float] = seq_plot.sequence_values()
	if not values.is_empty():
		var n_last: int = values.size() - 1
		end_marker.position = axes.to_global(axes.c2p(float(n_last), values[n_last]))
	info_label.text = "k=%.2f  x0=%.2f  x_last=%.4f" % [
		k_tracker.get_value(),
		x0_tracker.get_value(),
		seq_plot.latest_value(),
	]


func _map_value(x: float) -> float:
	return cos(x) + k_tracker.get_value()


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

