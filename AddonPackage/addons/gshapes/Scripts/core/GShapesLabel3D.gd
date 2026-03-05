class_name GShapesLabel3D
extends Node3D

var target_node: Node3D
var point_callable: Callable
var text_callable: Callable
var anchor_offset: Vector3 = Vector3(0.0, 0.35, 0.0)
var auto_update_position: bool = true
var auto_update_text: bool = true
var fixed_text: String = ""
var text_color: Color = Color(0.95, 0.96, 1.0)
var outline_color: Color = Color(0.08, 0.1, 0.16, 0.95)
var font_size: int = 28
var billboard_enabled: bool = true

var _label: Label3D


func _ready() -> void:
	_ensure_label()
	_apply_style()
	_sync_from_sources()


func _process(_delta: float) -> void:
	_sync_from_sources()


func set_target(node: Node3D) -> void:
	target_node = node
	_sync_from_sources()


func set_point_callable(source: Callable) -> void:
	point_callable = source
	_sync_from_sources()


func set_text_callable(source: Callable) -> void:
	text_callable = source
	_sync_from_sources()


func set_text(value: String) -> void:
	fixed_text = value
	if _label != null:
		_label.text = fixed_text


func get_label_node() -> Label3D:
	_ensure_label()
	return _label


func _sync_from_sources() -> void:
	_ensure_label()
	if auto_update_position and is_inside_tree():
		var sampled: Variant = _sample_world_point()
		if sampled is Vector3:
			global_position = sampled + anchor_offset

	if auto_update_text:
		var sampled_text: Variant = _sample_text()
		if sampled_text is String and not String(sampled_text).is_empty():
			_label.text = sampled_text
		else:
			_label.text = fixed_text


func _sample_world_point() -> Variant:
	if point_callable.is_valid():
		var v: Variant = point_callable.call()
		if v is Vector3:
			return v
	if target_node != null and is_instance_valid(target_node):
		return target_node.global_position
	return null


func _sample_text() -> Variant:
	if text_callable.is_valid():
		var v: Variant = text_callable.call()
		if v is String:
			return v
	return null


func _ensure_label() -> void:
	if _label != null:
		return
	_label = Label3D.new()
	add_child(_label)


func _apply_style() -> void:
	if _label == null:
		return
	_label.modulate = text_color
	_label.outline_modulate = outline_color
	_label.outline_size = 6
	_label.font_size = font_size
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED if billboard_enabled else BaseMaterial3D.BILLBOARD_DISABLED
	_label.no_depth_test = true



