# Demo: PortDemosRunner
# Expected behavior: Auto-cycle and manually cycle all port demos in one scene.

extends Node2D

var demo_scenes: Array[String] = []

var seconds_per_demo: float = 5.0
var auto_advance: bool = true

var index: int = 0
var elapsed: float = 0.0
var active_demo: Node

var title_label: Label
var scene_label: Label
var hint_label: Label


func _ready() -> void:
	title_label = Label.new()
	title_label.text = "Port Demos Runner"
	title_label.position = Vector2(16.0, 10.0)
	title_label.add_theme_font_size_override("font_size", 30)
	add_child(title_label)

	scene_label = Label.new()
	scene_label.position = Vector2(16.0, 52.0)
	scene_label.add_theme_font_size_override("font_size", 18)
	add_child(scene_label)

	hint_label = Label.new()
	hint_label.text = "Next/Prev Scene: cycle | Enter: reload demo | Reset: toggle auto-run"
	hint_label.position = Vector2(16.0, 78.0)
	hint_label.add_theme_font_size_override("font_size", 14)
	add_child(hint_label)

	demo_scenes = PortDemoCatalog.get_runner_demos()
	_load_demo(index)


func _process(delta: float) -> void:
	if not auto_advance:
		return
	elapsed += delta
	if elapsed >= seconds_per_demo:
		_next_demo()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Next Scene"):
		_next_demo()
	elif event.is_action_pressed("Previous Scene"):
		index = posmod(index - 1, max(1, demo_scenes.size()))
		_load_demo(index)
	elif event.is_action_pressed("ui_accept"):
		_load_demo(index)
	elif event.is_action_pressed("Reset"):
		auto_advance = not auto_advance
		_refresh_labels()


func _next_demo() -> void:
	index = (index + 1) % max(1, demo_scenes.size())
	_load_demo(index)


func _load_demo(new_index: int) -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		return

	elapsed = 0.0
	index = clampi(new_index, 0, demo_scenes.size() - 1)
	if active_demo != null:
		active_demo.queue_free()
		active_demo = null

	var path := demo_scenes[index]
	if not ResourceLoader.exists(path):
		scene_label.text = "Missing demo: %s" % path
		return

	var packed := load(path) as PackedScene
	if packed == null:
		scene_label.text = "Invalid scene: %s" % path
		return

	active_demo = packed.instantiate()
	add_child(active_demo)
	if active_demo is CanvasItem:
		(active_demo as CanvasItem).z_index = -10

	_refresh_labels()


func _refresh_labels() -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		return
	scene_label.text = "%d/%d | %s | auto:%s | %.1fs" % [
		index + 1,
		demo_scenes.size(),
		demo_scenes[index],
		"on" if auto_advance else "off",
		seconds_per_demo
	]
