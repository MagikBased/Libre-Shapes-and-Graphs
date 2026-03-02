# Demo: PortDemosSmokeCheck
# Expected behavior: Loads/instantiates each demo scene in-process and reports load status.

extends Node2D

var demo_scenes: Array[String] = []

var seconds_per_scene: float = 1.0
var index: int = -1
var elapsed: float = 0.0
var pass_count: int = 0
var fail_count: int = 0
var active_instance: Node
var failures: Array[String] = []

var status_label: Label
var detail_label: Label


func _ready() -> void:
	status_label = Label.new()
	status_label.position = Vector2(16.0, 12.0)
	status_label.add_theme_font_size_override("font_size", 22)
	add_child(status_label)

	detail_label = Label.new()
	detail_label.position = Vector2(16.0, 48.0)
	detail_label.add_theme_font_size_override("font_size", 16)
	add_child(detail_label)

	demo_scenes = PortDemoCatalog.get_smoke_demos()
	_next_scene()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= seconds_per_scene:
		_next_scene()


func _next_scene() -> void:
	elapsed = 0.0
	index += 1

	if active_instance != null:
		active_instance.queue_free()
		active_instance = null

	if index >= demo_scenes.size():
		status_label.text = "Smoke check complete: pass=%d fail=%d" % [pass_count, fail_count]
		if failures.is_empty():
			detail_label.text = "No failures. Reset to rerun."
		else:
			detail_label.text = "Failures:\n" + "\n".join(failures)
		set_process(false)
		return

	var path := demo_scenes[index]
	var ok := _try_load_and_instantiate(path)
	if ok:
		pass_count += 1
	else:
		fail_count += 1
		failures.append(path)

	status_label.text = "Smoke check %d/%d | pass=%d fail=%d" % [index + 1, demo_scenes.size(), pass_count, fail_count]
	detail_label.text = path


func _try_load_and_instantiate(path: String) -> bool:
	if not ResourceLoader.exists(path):
		return false
	var packed := load(path) as PackedScene
	if packed == null:
		return false
	active_instance = packed.instantiate()
	if active_instance == null:
		return false
	add_child(active_instance)
	if active_instance is CanvasItem:
		(active_instance as CanvasItem).visible = false
	return true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()
