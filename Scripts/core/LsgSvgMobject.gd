class_name LsgSvgMobject
extends LsgImageMobject

var _svg_path: String = ""
var svg_path: String:
	get:
		return _svg_path
	set(value):
		_svg_path = value
		source_path = _svg_path


func set_svg(path: String) -> LsgSvgMobject:
	svg_path = path
	return self
