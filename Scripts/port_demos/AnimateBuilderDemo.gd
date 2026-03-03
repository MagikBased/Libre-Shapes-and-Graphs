# Demo: AnimateBuilderDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var circles: Array[Circle] = []
var tracker: PortValueTracker
var tracker_label: PortTextMobject


func _ready() -> void:
	_create_caption("Animate builder demo: mob.animate chains and tracker.animate.set_value")
	_spawn_row()

	tracker = PortValueTracker.new(0.0)
	add_child(tracker)

	tracker_label = PortTextMobject.new()
	tracker_label.text = "value = 0.00"
	tracker_label.font_size = 32
	tracker_label.color = Color(0.9, 0.95, 1.0)
	tracker_label.position = Vector2(16.0, 56.0)
	add_child(tracker_label)
	tracker_label.add_updater(_update_tracker_label)

	play(circles[0].animate.move_to(Vector2(1000.0, circles[0].position.y)).set_run_time(1.0))
	wait(0.15)
	play(circles[1].animate.shift(Vector2(420.0, 0.0)).set_color(Color.GOLD).set_run_time(1.2))
	wait(0.15)
	play(circles[2].animate.scale_to(1.8).rotate_to(deg_to_rad(180.0)).set_run_time(1.1))
	wait(0.15)
	play([
		circles[3].animate.move_to(Vector2(1000.0, circles[3].position.y)).set_color(Color.LIME_GREEN).set_run_time(1.0),
		tracker.animate.set_value(4.0).set_run_time(1.0).set_rate_func(&"smooth"),
	])
	wait(0.15)
	play(tracker.animate.set_value(-2.0).set_run_time(1.0).set_rate_func(&"there_and_back_with_pause"))


func _spawn_row() -> void:
	var y := 170.0
	for i in range(4):
		var c := Circle.new()
		c.size = Vector2(54.0, 54.0)
		c.color = Color.from_hsv(float(i) / 4.0, 0.75, 1.0)
		c.position = Vector2(150.0, y)
		add_child(c)
		circles.append(c)
		y += 120.0


func _update_tracker_label(target: PortObject2D, _delta: float) -> void:
	target.text = "value = %.2f" % tracker.get_value()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
