# Demo: PlaySemanticsMapDemo
# Expected behavior: See PlandAndCopy/DEMO_NOTES.md

extends PortCompatibleScene

var group: PortGroup2D


func _ready() -> void:
	_create_caption("Play semantics demo: per-call overrides + lagged map orchestration")

	group = PortGroup2D.new()
	add_child(group)
	_build_members()

	play_lagged_map(
		group.get_members(),
		func(member: Node2D, i: int):
			var shape := member as PortObject2D
			return shape.animate.shift(Vector2(760.0, 0.0)).set_color(Color.from_hsv(float(i) / 8.0, 0.85, 1.0)),
		0.22,
		2.4,
		&"smooth"
	)
	wait(0.2)

	var return_builders: Array = []
	for member in group.get_members():
		return_builders.append((member as PortObject2D).animate.shift(Vector2(-760.0, 0.0)))
	play(return_builders, 1.1, &"there_and_back_with_pause")

	wait(0.2)
	var members := group.get_members()
	var first := members[0] as PortObject2D
	var fourth := members[3] as PortObject2D
	var seventh := members[6] as PortObject2D
	play([
		first.animate.scale_to(1.7),
		fourth.animate.rotate_to(deg_to_rad(225.0)),
		seventh.animate.set_opacity(0.35),
	], 0.9, &"overshoot")

	wait(0.2)
	play_map(
		members,
		func(member: Node2D):
			return (member as PortObject2D).animate.set_opacity(0.6),
		0.55,
		&"there_and_back"
	)


func _build_members() -> void:
	var left := 180.0
	for i in range(8):
		var c := Circle.new()
		c.size = Vector2(52.0, 52.0)
		c.color = Color.WHITE
		c.position = Vector2(left, 120.0 + float(i) * 72.0)
		add_child(c)
		group.add_member(c)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)
