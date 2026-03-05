class_name PortFlatScene3D
extends Port3DScene

var canvas_size: Vector2i = Vector2i(1280, 720)
var pixels_per_unit: float = 160.0
var canvas_clear_color: Color = Color(0.03, 0.04, 0.06, 1.0)
var use_orthographic_projection: bool = true
var orthographic_size: float = 4.5

var _canvas_viewport: SubViewport
var _canvas_root: Node2D
var _canvas_sprite: Sprite3D


func _ready() -> void:
	super._ready()
	_setup_flat_canvas()
	_apply_projection_mode()


func get_canvas_root() -> Node2D:
	return _canvas_root


func get_canvas_viewport() -> SubViewport:
	return _canvas_viewport


func get_canvas_plane() -> Node3D:
	return _canvas_sprite


func frame_canvas(padding: float = 1.1) -> void:
	if _canvas_sprite == null:
		return
	frame_nodes([_canvas_sprite], padding)


func set_projection_mode_orthographic(enabled: bool) -> void:
	use_orthographic_projection = enabled
	_apply_projection_mode()


func _setup_flat_canvas() -> void:
	_canvas_viewport = SubViewport.new()
	_canvas_viewport.disable_3d = true
	_canvas_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_canvas_viewport.size = canvas_size
	_canvas_viewport.transparent_bg = false
	_canvas_viewport.msaa_2d = Viewport.MSAA_2X
	add_child(_canvas_viewport)
	_canvas_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	_canvas_viewport.gui_disable_input = true

	var bg := ColorRect.new()
	bg.color = canvas_clear_color
	bg.position = Vector2.ZERO
	bg.size = Vector2(canvas_size)
	_canvas_viewport.add_child(bg)

	_canvas_root = Node2D.new()
	_canvas_root.position = Vector2.ZERO
	_canvas_viewport.add_child(_canvas_root)

	_canvas_sprite = Sprite3D.new()
	_canvas_sprite.texture = _canvas_viewport.get_texture()
	_canvas_sprite.pixel_size = 1.0 / maxf(1.0, pixels_per_unit)
	_canvas_sprite.centered = true
	add_child(_canvas_sprite)


func _apply_projection_mode() -> void:
	if camera == null:
		return
	if use_orthographic_projection:
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = orthographic_size
	else:
		camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		camera.fov = camera_fov
