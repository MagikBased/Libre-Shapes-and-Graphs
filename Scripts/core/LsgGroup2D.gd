class_name LsgGroup2D
extends LsgObject2D

var members: Array[Node2D] = []


func _init(initial_members: Array = []) -> void:
	add_members(initial_members)


func add_member(member: Node2D) -> LsgGroup2D:
	if member == null:
		return self
	if members.has(member):
		return self
	members.append(member)
	return self


func add_members(new_members: Array) -> LsgGroup2D:
	for item in new_members:
		if item is Node2D:
			add_member(item as Node2D)
	return self


func remove_member(member: Node2D) -> LsgGroup2D:
	var index: int = members.find(member)
	if index >= 0:
		members.remove_at(index)
	return self


func clear_members() -> LsgGroup2D:
	members.clear()
	return self


func get_members() -> Array[Node2D]:
	return members.duplicate()


func for_each_member(action: Callable) -> void:
	if not action.is_valid():
		return
	for i in range(members.size()):
		action.call(members[i], i)


func arrange_linear(
	direction: Vector2 = Vector2.RIGHT,
	spacing: float = 64.0,
	centered: bool = true
) -> LsgGroup2D:
	return arrange(direction, spacing, centered)


func arrange(
	direction: Vector2 = Vector2.RIGHT,
	spacing: float = 64.0,
	centered: bool = true
) -> LsgGroup2D:
	return apply_positions(compute_linear_positions(direction, spacing, centered))


func arrange_in_grid(
	rows: int = 0,
	cols: int = 0,
	cell_size: Vector2 = Vector2(96.0, 96.0),
	centered: bool = true
) -> LsgGroup2D:
	return apply_positions(compute_grid_positions(rows, cols, cell_size, centered))


func compute_linear_positions(
	direction: Vector2 = Vector2.RIGHT,
	spacing: float = 64.0,
	centered: bool = true
) -> Array[Vector2]:
	var out: Array[Vector2] = []
	if members.is_empty():
		return out
	var unit: Vector2 = direction.normalized()
	if unit == Vector2.ZERO:
		unit = Vector2.RIGHT
	var start: float = 0.0
	if centered:
		start = -0.5 * spacing * float(members.size() - 1)
	for i in range(members.size()):
		out.append(unit * (start + spacing * float(i)))
	return out


func compute_grid_positions(
	rows: int = 0,
	cols: int = 0,
	cell_size: Vector2 = Vector2(96.0, 96.0),
	centered: bool = true
) -> Array[Vector2]:
	var out: Array[Vector2] = []
	var n: int = members.size()
	if n <= 0:
		return out

	var resolved_cols: int = cols
	var resolved_rows: int = rows
	if resolved_rows <= 0 and resolved_cols <= 0:
		resolved_cols = int(ceil(sqrt(float(n))))
		resolved_rows = int(ceil(float(n) / float(resolved_cols)))
	elif resolved_rows <= 0:
		resolved_cols = maxi(1, resolved_cols)
		resolved_rows = int(ceil(float(n) / float(resolved_cols)))
	elif resolved_cols <= 0:
		resolved_rows = maxi(1, resolved_rows)
		resolved_cols = int(ceil(float(n) / float(resolved_rows)))

	resolved_cols = maxi(1, resolved_cols)
	resolved_rows = maxi(1, resolved_rows)
	var spacing: Vector2 = Vector2(maxf(1.0, cell_size.x), maxf(1.0, cell_size.y))
	var used_cols: int = mini(resolved_cols, n)
	var used_rows: int = int(ceil(float(n) / float(resolved_cols)))
	var offset: Vector2 = Vector2.ZERO
	if centered:
		offset = Vector2(
			0.5 * spacing.x * float(used_cols - 1),
			0.5 * spacing.y * float(used_rows - 1)
		)

	for i in range(n):
		var r: int = int(floor(float(i) / float(resolved_cols)))
		var c: int = i % resolved_cols
		var p: Vector2 = Vector2(float(c) * spacing.x, float(r) * spacing.y) - offset
		out.append(p)
	return out


func apply_positions(positions: Array[Vector2]) -> LsgGroup2D:
	var count: int = mini(members.size(), positions.size())
	for i in range(count):
		members[i].position = positions[i]
	return self


func move_group_to(center_position: Vector2) -> LsgGroup2D:
	if members.is_empty():
		return self
	var centroid: Vector2 = Vector2.ZERO
	for member in members:
		centroid += member.position
	centroid /= float(members.size())
	var delta: Vector2 = center_position - centroid
	for member in members:
		member.position += delta
	return self


func set_group_color(group_color: Color) -> LsgGroup2D:
	for member in members:
		if member is LsgObject2D:
			(member as LsgObject2D).color = group_color
		else:
			member.modulate = group_color
	return self
