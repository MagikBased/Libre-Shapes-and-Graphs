class_name PortGroup2D
extends PortObject2D

var members: Array[Node2D] = []


func _init(initial_members: Array = []) -> void:
	add_members(initial_members)


func add_member(member: Node2D) -> PortGroup2D:
	if member == null:
		return self
	if members.has(member):
		return self
	members.append(member)
	return self


func add_members(new_members: Array) -> PortGroup2D:
	for item in new_members:
		if item is Node2D:
			add_member(item as Node2D)
	return self


func remove_member(member: Node2D) -> PortGroup2D:
	var index := members.find(member)
	if index >= 0:
		members.remove_at(index)
	return self


func clear_members() -> PortGroup2D:
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
) -> PortGroup2D:
	if members.is_empty():
		return self
	var unit := direction.normalized()
	if unit == Vector2.ZERO:
		unit = Vector2.RIGHT
	var start := 0.0
	if centered:
		start = -0.5 * spacing * float(members.size() - 1)
	for i in range(members.size()):
		members[i].position = unit * (start + spacing * float(i))
	return self


func move_group_to(center_position: Vector2) -> PortGroup2D:
	if members.is_empty():
		return self
	var centroid := Vector2.ZERO
	for member in members:
		centroid += member.position
	centroid /= float(members.size())
	var delta := center_position - centroid
	for member in members:
		member.position += delta
	return self


func set_group_color(group_color: Color) -> PortGroup2D:
	for member in members:
		if member is PortObject2D:
			(member as PortObject2D).color = group_color
		else:
			member.modulate = group_color
	return self
