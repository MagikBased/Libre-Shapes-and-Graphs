class_name LsgVector3D
extends Node3D

var start_point: Vector3 = Vector3.ZERO
var end_point: Vector3 = Vector3(0.0, 1.0, 0.0)
var shaft_radius: float = 0.045
var tip_radius: float = 0.11
var tip_length_ratio: float = 0.24
var min_tip_length: float = 0.16
var max_tip_length: float = 0.8
var vector_color: Color = Color(0.98, 0.7, 0.26)

var _shaft: MeshInstance3D
var _tip: MeshInstance3D


func _ready() -> void:
	_ensure_nodes()
	rebuild()


func set_points(start: Vector3, finish: Vector3) -> void:
	start_point = start
	end_point = finish
	rebuild()


func set_from_origin(direction: Vector3) -> void:
	set_points(Vector3.ZERO, direction)


func set_color(color: Color) -> void:
	vector_color = color
	_apply_materials()


func rebuild() -> void:
	_ensure_nodes()

	var delta: Vector3 = end_point - start_point
	var length: float = delta.length()
	if length <= 0.0001:
		_shaft.visible = false
		_tip.visible = false
		position = start_point
		return

	_shaft.visible = true
	_tip.visible = true
	position = start_point

	var dir: Vector3 = delta / length
	var up_hint: Vector3 = Vector3.UP
	if absf(dir.dot(up_hint)) > 0.98:
		up_hint = Vector3.RIGHT
	look_at(start_point + dir, up_hint, true)

	var tip_length: float = clampf(length * tip_length_ratio, min_tip_length, max_tip_length)
	tip_length = minf(tip_length, length * 0.9)
	var shaft_length: float = maxf(0.001, length - tip_length)

	var shaft_mesh: BoxMesh = _shaft.mesh as BoxMesh
	if shaft_mesh == null:
		shaft_mesh = BoxMesh.new()
		_shaft.mesh = shaft_mesh
	shaft_mesh.size = Vector3(shaft_radius * 2.0, shaft_radius * 2.0, shaft_length)
	_shaft.position = Vector3(0.0, 0.0, -shaft_length * 0.5)

	var tip_mesh: CylinderMesh = _tip.mesh as CylinderMesh
	if tip_mesh == null:
		tip_mesh = CylinderMesh.new()
		_tip.mesh = tip_mesh
	tip_mesh.top_radius = 0.0
	tip_mesh.bottom_radius = tip_radius
	tip_mesh.height = tip_length
	tip_mesh.radial_segments = 14
	_tip.rotation = Vector3(-PI * 0.5, 0.0, 0.0)
	_tip.position = Vector3(0.0, 0.0, -(shaft_length + tip_length * 0.5))

	_apply_materials()


func _ensure_nodes() -> void:
	if _shaft == null:
		_shaft = MeshInstance3D.new()
		add_child(_shaft)
	if _tip == null:
		_tip = MeshInstance3D.new()
		add_child(_tip)


func _apply_materials() -> void:
	if _shaft == null or _tip == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = vector_color
	mat.roughness = 0.4
	mat.metallic = 0.06
	_shaft.material_override = mat
	_tip.material_override = mat
