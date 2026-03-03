class_name PortDecimalNumber
extends PortTextMobject

var _value: float = 0.0
var value: float:
	get:
		return _value
	set(v):
		_value = v
		_refresh_text()

var num_decimal_places: int = 2
var include_sign: bool = false
var unit_text: String = ""
var value_source: Callable
var update_from_source_each_frame: bool = true


func _init(
	p_value: float = 0.0,
	p_num_decimal_places: int = 2,
	p_include_sign: bool = false,
	p_unit_text: String = ""
) -> void:
	_value = p_value
	num_decimal_places = maxi(0, p_num_decimal_places)
	include_sign = p_include_sign
	unit_text = p_unit_text


func _ready() -> void:
	super._ready()
	_refresh_text()


func _process(delta: float) -> void:
	super._process(delta)
	if not update_from_source_each_frame:
		return
	if not value_source.is_valid():
		return
	var next_value = value_source.call()
	if next_value is float or next_value is int:
		set_value(float(next_value))


func set_value(v: float) -> void:
	value = v


func get_value() -> float:
	return value


func set_value_source(source: Callable, p_update_each_frame: bool = true) -> void:
	value_source = source
	update_from_source_each_frame = p_update_each_frame
	if update_from_source_each_frame:
		_process_source_once()


func set_format(p_num_decimal_places: int, p_include_sign: bool = false, p_unit_text: String = "") -> void:
	num_decimal_places = maxi(0, p_num_decimal_places)
	include_sign = p_include_sign
	unit_text = p_unit_text
	_refresh_text()


func _process_source_once() -> void:
	if not value_source.is_valid():
		return
	var next_value = value_source.call()
	if next_value is float or next_value is int:
		set_value(float(next_value))


func _refresh_text() -> void:
	var abs_format := "%0." + str(num_decimal_places) + "f"
	var magnitude := absf(value)
	var body := abs_format % magnitude
	var signed_text := body
	if is_zero_approx(value):
		if include_sign:
			signed_text = "+" + body
	elif value < 0.0:
		signed_text = "-" + body
	elif include_sign:
		signed_text = "+" + body
	text = signed_text + unit_text
