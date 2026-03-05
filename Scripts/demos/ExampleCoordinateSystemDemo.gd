# Demo: ExampleCoordinateSystemDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends LsgCompatibleScene

var axes: GraphAxes2D
var dot: Circle
var h_line: Line
var v_line: Line

var x_tracker: LsgValueTracker
var y_tracker: LsgValueTracker


func _ready() -> void:
	_create_caption("CoordinateSystemExample adaptation: tracked point with guide lines")

	axes = GraphAxes2D.new()
	axes.position = Vector2(140.0, 120.0)
	axes.viewport_size = Vector2(980.0, 520.0)
	axes.x_min = -1.0
	axes.x_max = 10.0
	axes.y_min = -2.0
	axes.y_max = 2.0
	axes.tick_step_x = 1.0
	axes.tick_step_y = 0.5
	add_child(axes)
	axes.add_coordinate_labels(12, false)

	x_tracker = GShapes.ValueTracker.new(0.0)
	y_tracker = GShapes.ValueTracker.new(0.0)
	add_child(x_tracker)
	add_child(y_tracker)

	dot = Circle.new()
	dot.size = Vector2(20.0, 20.0)
	dot.color = Color.RED
	add_child(dot)
	dot.add_updater(_update_dot_position)

	h_line = Line.new()
	h_line.color = Color(0.9, 0.9, 0.9)
	h_line.stroke_width = 2.0
	h_line.modulate.a = 0.0
	add_child(h_line)
	h_line.add_updater(_update_h_line)

	v_line = Line.new()
	v_line.color = Color(0.9, 0.9, 0.9)
	v_line.stroke_width = 2.0
	v_line.modulate.a = 0.0
	add_child(v_line)
	v_line.add_updater(_update_v_line)

	play_group([
		GShapes.FadeIn.new(dot, 0.35, &"smooth"),
		GShapes.FadeIn.new(h_line, 0.35, &"smooth"),
		GShapes.FadeIn.new(v_line, 0.35, &"smooth"),
	])
	play_sequence([
		_move_trackers(3.0, 2.0, 1.2),
		_move_trackers(5.0, 0.5, 1.2),
		_move_trackers(3.0, -2.0, 1.2),
		_move_trackers(1.0, 1.0, 1.2),
		GShapes.Transform.new(axes, Vector2(40.0, 60.0), Vector2(0.75, 0.75), null, 1.6, &"smooth"),
	])


func _move_trackers(x_value: float, y_value: float, duration: float) -> LsgAnimationGroup:
	return GShapes.AnimationGroup.new([
		GShapes.SetValue.new(x_tracker, x_value, duration, &"smooth"),
		GShapes.SetValue.new(y_tracker, y_value, duration, &"smooth"),
	])


func _update_dot_position(target: LsgObject2D, _delta: float) -> void:
	var local_point := axes.c2p(x_tracker.get_value(), y_tracker.get_value())
	target.position = axes.to_global(local_point)


func _update_h_line(target: LsgObject2D, _delta: float) -> void:
	var local_point := axes.c2p(x_tracker.get_value(), y_tracker.get_value())
	var points := axes.get_h_line_points(local_point)
	target.set_endpoints(axes.to_global(points[0]), axes.to_global(points[1]))


func _update_v_line(target: LsgObject2D, _delta: float) -> void:
	var local_point := axes.c2p(x_tracker.get_value(), y_tracker.get_value())
	var points := axes.get_v_line_points(local_point)
	target.set_endpoints(axes.to_global(points[0]), axes.to_global(points[1]))


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
