# Demo: GroupLayoutParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var group: LsgGroup2D


func _ready() -> void:
	_create_caption("Phase 6 group layout parity: arrange + arrange_in_grid workflows")

	group = GShapes.Group2D.new()
	add_child(group)
	_build_members()

	var line_targets := _offset_points(
		group.compute_linear_positions(Vector2.RIGHT, 88.0, true),
		Vector2(640.0, 210.0)
	)
	play_lagged_map(
		group.get_members(),
		func(member: Node2D, i: int):
			return GShapes.MoveTo.new(member, line_targets[i], 0.9, &"smooth"),
		0.07,
		1.1,
		&"smooth"
	)

	wait(0.2)
	var grid_targets := _offset_points(
		group.compute_grid_positions(3, 4, Vector2(120.0, 110.0), true),
		Vector2(640.0, 410.0)
	)
	play_map(
		group.get_members(),
		func(member: Node2D, i: int):
			return GShapes.MoveTo.new(member, grid_targets[i], 1.0, &"smooth"),
		1.0,
		&"smooth"
	)

	wait(0.2)
	play_lagged_map(
		group.get_members(),
		func(member: Node2D, i: int):
			return (member as LsgObject2D).animate.set_color(Color.from_hsv(float(i) / 12.0, 0.7, 1.0)),
		0.05,
		0.8,
		&"smooth"
	)


func _build_members() -> void:
	for i in range(12):
		var c := Circle.new()
		c.size = Vector2(46.0, 46.0)
		c.color = Color.WHITE
		var x := 160.0 + float(i % 4) * 48.0
		var y: float = 180.0 + floor(float(i) / 4.0) * 48.0
		c.position = Vector2(x, y)
		add_child(c)
		group.add_member(c)


func _offset_points(points: Array[Vector2], offset: Vector2) -> Array[Vector2]:
	var out: Array[Vector2] = []
	for p in points:
		out.append(p + offset)
	return out


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

