# Demo: ReturnMapParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var axes: GraphAxes2D
var return_map: LsgReturnMap2D
var parameter_tracker: LsgValueTracker
var diagonal: LsgPolylineMobject
var info_label: Label


func _ready() -> void:
	_create_caption("Phase 6 return-map parity: x_n vs x_{n+1} for logistic-map iteration")

	axes = GraphAxes2D.new()
	axes.position = Vector2(120.0, 92.0)
	axes.viewport_size = Vector2(980.0, 560.0)
	axes.x_min = 0.0
	axes.x_max = 1.0
	axes.y_min = 0.0
	axes.y_max = 1.0
	add_child(axes)
	axes.add_coordinate_labels(11, false)

	diagonal = GShapes.PolylineMobject.new()
	diagonal.position = axes.position
	diagonal.color = Color(0.92, 0.96, 1.0, 0.45)
	diagonal.stroke_width = 1.5
	diagonal.points = PackedVector2Array([
		axes.c2p(0.0, 0.0),
		axes.c2p(1.0, 1.0),
	])
	add_child(diagonal)

	parameter_tracker = GShapes.ValueTracker.new(3.6)
	add_child(parameter_tracker)

	return_map = GShapes.ReturnMap2D.new()
	return_map.axes = axes
	return_map.position = axes.position
	return_map.map_callable = Callable(self, "_logistic_map")
	return_map.parameter_value = parameter_tracker.get_value()
	return_map.initial_value = 0.314159
	return_map.settle_iterations = 42
	return_map.sample_iterations = 220
	return_map.point_radius = 1.1
	return_map.alpha = 0.88
	return_map.auto_update = false
	return_map.rebuild()
	add_child(return_map)

	info_label = Label.new()
	info_label.position = Vector2(16.0, 42.0)
	info_label.modulate = Color(0.88, 0.95, 1.0)
	add_child(info_label)

	play(GShapes.FadeIn.new(return_map, 0.5, &"smooth"))
	play_sequence([
		GShapes.SetValue.new(parameter_tracker, 3.74, 1.2, &"smooth"),
		GShapes.SetValue.new(parameter_tracker, 3.89, 1.3, &"there_and_back_with_pause"),
		GShapes.SetValue.new(parameter_tracker, 3.64, 1.0, &"smooth"),
	])


func _process(_delta: float) -> void:
	if return_map == null:
		return
	return_map.parameter_value = parameter_tracker.get_value()
	return_map.rebuild()
	info_label.text = "r=%.3f  points=%d  return map: (x_n, x_{n+1})" % [
		parameter_tracker.get_value(),
		return_map.point_count(),
	]


func _logistic_map(x: float, r: float) -> float:
	return r * x * (1.0 - x)


func _create_caption(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

