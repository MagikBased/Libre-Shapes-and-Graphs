class_name GShapesGroup3D
extends Node3D

var members: Array[Node3D] = []


func _init(initial_members: Array = []) -> void:
	add_members(initial_members)


func add_member(member: Node3D) -> GShapesGroup3D:
	if member == null:
		return self
	if members.has(member):
		return self
	members.append(member)
	return self


func add_members(new_members: Array) -> GShapesGroup3D:
	for item in new_members:
		if item is Node3D:
			add_member(item as Node3D)
	return self


func remove_member(member: Node3D) -> GShapesGroup3D:
	var idx: int = members.find(member)
	if idx >= 0:
		members.remove_at(idx)
	return self


func clear_members() -> GShapesGroup3D:
	members.clear()
	return self


func get_members() -> Array[Node3D]:
	return members.duplicate()


func compute_linear_positions(
	direction: Vector3 = Vector3.RIGHT,
	spacing: float = 1.2,
	centered: bool = true
) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if members.is_empty():
		return out
	var unit: Vector3 = direction.normalized()
	if unit == Vector3.ZERO:
		unit = Vector3.RIGHT
	var start: float = 0.0
	if centered:
		start = -0.5 * spacing * float(members.size() - 1)
	for i in range(members.size()):
		out.append(unit * (start + spacing * float(i)))
	return out


func compute_grid_xz_positions(
	rows: int = 0,
	cols: int = 0,
	cell_size: Vector2 = Vector2(1.4, 1.4),
	centered: bool = true
) -> Array[Vector3]:
	var out: Array[Vector3] = []
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
	var sx: float = maxf(0.2, cell_size.x)
	var sz: float = maxf(0.2, cell_size.y)

	var used_cols: int = mini(resolved_cols, n)
	var used_rows: int = int(ceil(float(n) / float(resolved_cols)))
	var offset_x: float = 0.0
	var offset_z: float = 0.0
	if centered:
		offset_x = 0.5 * sx * float(used_cols - 1)
		offset_z = 0.5 * sz * float(used_rows - 1)

	for i in range(n):
		var r: int = int(floor(float(i) / float(resolved_cols)))
		var c: int = i % resolved_cols
		out.append(Vector3(float(c) * sx - offset_x, 0.0, float(r) * sz - offset_z))
	return out


func apply_positions(positions: Array[Vector3]) -> GShapesGroup3D:
	var count: int = mini(members.size(), positions.size())
	for i in range(count):
		members[i].position = positions[i]
	return self


func move_group_to(center_position: Vector3) -> GShapesGroup3D:
	if members.is_empty():
		return self
	var centroid: Vector3 = get_members_centroid()
	var delta: Vector3 = center_position - centroid
	for member in members:
		member.position += delta
	return self


func get_members_centroid() -> Vector3:
	if members.is_empty():
		return Vector3.ZERO
	var centroid: Vector3 = Vector3.ZERO
	for member in members:
		centroid += member.position
	return centroid / float(members.size())



