class_name LsgAxes3D
extends Node3D

var axis_length: float = 3.4
var axis_thickness: float = 0.04
var tip_radius: float = 0.09
var tip_height: float = 0.24
var show_negative_axes: bool = true

var x_color: Color = Color(1.0, 0.4, 0.35)
var y_color: Color = Color(0.45, 1.0, 0.5)
var z_color: Color = Color(0.45, 0.7, 1.0)


func _ready() -> void:
	rebuild()


func rebuild() -> void:
	for child in get_children():
		var node: Node = child
		node.queue_free()

	var axis_len: float = maxf(0.2, axis_length)
	var thick: float = maxf(0.005, axis_thickness)
	var tip_r: float = maxf(thick * 1.6, tip_radius)
	var tip_h: float = maxf(tip_r * 1.5, tip_height)

	_add_axis_x(axis_len, thick, tip_r, tip_h, x_color)
	_add_axis_y(axis_len, thick, tip_r, tip_h, y_color)
	_add_axis_z(axis_len, thick, tip_r, tip_h, z_color)

	if show_negative_axes:
		var dim := 0.45
		_add_axis_x_negative(axis_len, thick, x_color.darkened(dim))
		_add_axis_y_negative(axis_len, thick, y_color.darkened(dim))
		_add_axis_z_negative(axis_len, thick, z_color.darkened(dim))


func _add_axis_x(axis_len: float, thick: float, tip_r: float, tip_h: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(axis_len, thick, thick), color)
	shaft.position = Vector3(axis_len * 0.5, 0.0, 0.0)
	add_child(shaft)

	var tip := _make_cone_tip(tip_r, tip_h, color)
	tip.position = Vector3(axis_len + tip_h * 0.5, 0.0, 0.0)
	tip.rotate_z(-PI * 0.5)
	add_child(tip)


func _add_axis_y(axis_len: float, thick: float, tip_r: float, tip_h: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(thick, axis_len, thick), color)
	shaft.position = Vector3(0.0, axis_len * 0.5, 0.0)
	add_child(shaft)

	var tip := _make_cone_tip(tip_r, tip_h, color)
	tip.position = Vector3(0.0, axis_len + tip_h * 0.5, 0.0)
	add_child(tip)


func _add_axis_z(axis_len: float, thick: float, tip_r: float, tip_h: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(thick, thick, axis_len), color)
	shaft.position = Vector3(0.0, 0.0, axis_len * 0.5)
	add_child(shaft)

	var tip := _make_cone_tip(tip_r, tip_h, color)
	tip.position = Vector3(0.0, 0.0, axis_len + tip_h * 0.5)
	tip.rotate_x(PI * 0.5)
	add_child(tip)


func _add_axis_x_negative(axis_len: float, thick: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(axis_len, thick, thick), color)
	shaft.position = Vector3(-axis_len * 0.5, 0.0, 0.0)
	add_child(shaft)


func _add_axis_y_negative(axis_len: float, thick: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(thick, axis_len, thick), color)
	shaft.position = Vector3(0.0, -axis_len * 0.5, 0.0)
	add_child(shaft)


func _add_axis_z_negative(axis_len: float, thick: float, color: Color) -> void:
	var shaft := _make_box_mesh(Vector3(thick, thick, axis_len), color)
	shaft.position = Vector3(0.0, 0.0, -axis_len * 0.5)
	add_child(shaft)


func _make_box_mesh(size: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var mesh := MeshInstance3D.new()
	mesh.mesh = box
	mesh.material_override = _make_material(color)
	return mesh


func _make_cone_tip(radius: float, height: float, color: Color) -> MeshInstance3D:
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = radius
	cone.height = height
	cone.radial_segments = 14
	var mesh := MeshInstance3D.new()
	mesh.mesh = cone
	mesh.material_override = _make_material(color)
	return mesh


func _make_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.45
	mat.metallic = 0.05
	return mat
