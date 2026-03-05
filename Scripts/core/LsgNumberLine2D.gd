class_name LsgNumberLine2D
extends LsgObject2D

var x_min: float = -5.0
var x_max: float = 5.0
var unit_size: float = 90.0
var tick_step: float = 1.0
var tick_size: float = 10.0
var stroke_width: float = 3.0
var include_numbers: bool = true
var label_precision: int = 0
var label_offset_y: float = 16.0

var _labels: Array[Label] = []


func _ready() -> void:
	_rebuild_labels()


func _process(delta: float) -> void:
	super._process(delta)
	for label in _labels:
		label.modulate = color


func set_range(p_min: float, p_max: float) -> void:
	x_min = p_min
	x_max = maxf(p_min + 0.001, p_max)
	_rebuild_labels()
	queue_redraw()


func set_tick_step(step: float) -> void:
	tick_step = maxf(0.001, step)
	_rebuild_labels()
	queue_redraw()


func number_to_local(value: float) -> Vector2:
	return Vector2((value - x_min) * unit_size, 0.0)


func local_to_number(local_pos: Vector2) -> float:
	return x_min + (local_pos.x / maxf(0.0001, unit_size))


func refresh() -> void:
	_rebuild_labels()
	queue_redraw()


func _draw() -> void:
	var start := number_to_local(x_min)
	var end := number_to_local(x_max)
	draw_line(start, end, color, stroke_width)

	var t := x_min
	var guard := 0
	while t <= x_max + 0.0001 and guard < 10000:
		var p := number_to_local(t)
		draw_line(
			p + Vector2(0.0, -tick_size * 0.5),
			p + Vector2(0.0, tick_size * 0.5),
			color,
			stroke_width
		)
		t += tick_step
		guard += 1


func _rebuild_labels() -> void:
	for label in _labels:
		if is_instance_valid(label):
			label.queue_free()
	_labels.clear()

	if not include_numbers:
		return

	var fmt := "%0." + str(maxi(0, label_precision)) + "f"
	var t := x_min
	var guard := 0
	while t <= x_max + 0.0001 and guard < 10000:
		var label := Label.new()
		label.text = fmt % t
		label.add_theme_font_size_override("font_size", 16)
		var p := number_to_local(t)
		label.position = Vector2(p.x - 12.0, label_offset_y)
		label.modulate = color
		add_child(label)
		_labels.append(label)
		t += tick_step
		guard += 1
