class_name PortTextMobject
extends PortObject2D

var _text: String = ""
var text: String:
	get:
		return _text
	set(value):
		_text = value
		if _label != null:
			_label.text = _text
			_update_reveal()
var _font_size: int = 48
var font_size: int:
	get:
		return _font_size
	set(value):
		_font_size = maxi(1, value)
		if _label != null:
			_label.add_theme_font_size_override("font_size", _font_size)
var _reveal_progress: float = 1.0
var reveal_progress: float:
	get:
		return _reveal_progress
	set(value):
		_reveal_progress = clampf(value, 0.0, 1.0)
		_update_reveal()

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.text = text
	_label.add_theme_font_size_override("font_size", font_size)
	_label.modulate = color
	add_child(_label)
	_update_reveal()


func _process(delta: float) -> void:
	super._process(delta)
	if _label != null:
		_label.modulate = color


func set_reveal_progress(progress: float) -> void:
	reveal_progress = progress


func get_visible_text() -> String:
	if _label == null:
		return ""
	var n := int(floor(float(text.length()) * reveal_progress))
	n = clampi(n, 0, text.length())
	return text.substr(0, n)


func get_string_bounds() -> Rect2:
	if _label == null:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	return Rect2(_label.position, _label.get_minimum_size())


func _update_reveal() -> void:
	if _label == null:
		return
	var total := text.length()
	_label.visible_characters = int(round(float(total) * reveal_progress))
