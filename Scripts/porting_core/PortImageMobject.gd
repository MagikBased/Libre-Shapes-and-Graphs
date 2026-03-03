class_name PortImageMobject
extends PortObject2D

var _source_path: String = ""
var source_path: String:
	get:
		return _source_path
	set(value):
		_source_path = value
		_load_from_path()

var _centered: bool = true
var centered: bool:
	get:
		return _centered
	set(value):
		_centered = value
		if _sprite != null:
			_sprite.centered = _centered

var _fit_size: Vector2 = Vector2.ZERO
var fit_size: Vector2:
	get:
		return _fit_size
	set(value):
		_fit_size = value
		_apply_fit_size()

var _keep_aspect: bool = true
var keep_aspect: bool:
	get:
		return _keep_aspect
	set(value):
		_keep_aspect = value
		_apply_fit_size()

var _sprite: Sprite2D
var _texture: Texture2D


func _ready() -> void:
	_ensure_sprite()
	_load_from_path()
	_sync_visual_state()


func _process(delta: float) -> void:
	super._process(delta)
	_sync_visual_state()


func set_texture(texture: Texture2D) -> void:
	_texture = texture
	_ensure_sprite()
	_sprite.texture = _texture
	_apply_fit_size()


func get_texture_size() -> Vector2:
	if _texture == null:
		return Vector2.ZERO
	return _texture.get_size()


func _load_from_path() -> void:
	if _source_path.is_empty():
		return
	var loaded := load(_source_path)
	if loaded is Texture2D:
		set_texture(loaded as Texture2D)


func _ensure_sprite() -> void:
	if _sprite != null:
		return
	_sprite = Sprite2D.new()
	_sprite.centered = _centered
	add_child(_sprite)


func _apply_fit_size() -> void:
	if _sprite == null or _texture == null:
		return
	var tex_size := _texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	if fit_size == Vector2.ZERO:
		_sprite.scale = Vector2.ONE
		return
	if keep_aspect:
		var factor := minf(fit_size.x / tex_size.x, fit_size.y / tex_size.y)
		factor = maxf(0.001, factor)
		_sprite.scale = Vector2.ONE * factor
	else:
		_sprite.scale = Vector2(
			maxf(0.001, fit_size.x / tex_size.x),
			maxf(0.001, fit_size.y / tex_size.y)
		)


func _sync_visual_state() -> void:
	if _sprite == null:
		return
	_sprite.modulate = color
