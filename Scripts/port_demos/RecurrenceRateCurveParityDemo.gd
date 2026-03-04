# Demo: RecurrenceRateCurveParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var axes: GraphAxes2D
var rr_curve: PortRecurrenceRateCurve2D
var parameter_tracker: PortValueTracker
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 recurrence-rate curve parity: RR(epsilon) for logistic-map sequences")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 0.08
	axes.y_min = 0.0
	axes.y_max = 1.0
	add_child(axes)
	axes.add_coordinate_labels(9, false)

	parameter_tracker = PortValueTracker.new(3.85)
	add_child(parameter_tracker)

	rr_curve = PortRecurrenceRateCurve2D.new()
	rr_curve.axes = axes
	rr_curve.position = axes.position
	rr_curve.map_callable = Callable(self, "_logistic_map")
	rr_curve.parameter_value = parameter_tracker.get_value()
	rr_curve.initial_value = 0.236
	rr_curve.settle_iterations = 140
	rr_curve.sequence_length = 160
	rr_curve.threshold_min = 0.001
	rr_curve.threshold_max = 0.08
	rr_curve.threshold_samples = 72
	rr_curve.stroke_width = 2.0
	rr_curve.auto_update = false
	rr_curve.rebuild()
	add_child(rr_curve)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(PortFadeIn.new(rr_curve, 0.5, &"smooth"))
	play_sequence([
		PortSetValue.new(parameter_tracker, 3.71, 1.2, &"smooth"),
		PortSetValue.new(parameter_tracker, 3.92, 1.3, &"there_and_back_with_pause"),
		PortSetValue.new(parameter_tracker, 3.84, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if rr_curve == null:
		return
	rr_curve.parameter_value = parameter_tracker.get_value()
	rr_curve.rebuild()
	info_label.text = "r=%.3f  samples=%d  peak RR=%.3f" % [
		parameter_tracker.get_value(),
		rr_curve.sample_count(),
		rr_curve.peak_rate(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
