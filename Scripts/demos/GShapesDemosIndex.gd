# Demo: GShapesDemosIndex
# Expected behavior: Browse/launch all demos from one scene.

extends Node2D

var demo_scenes: Array[String] = []

var index: int = 0
var title_label: Label
var scene_label: Label
var hint_label: Label


func _ready() -> void:
	title_label = Label.new()
	title_label.text = "Demos Index"
	title_label.position = Vector2(20.0, 16.0)
	title_label.add_theme_font_size_override("font_size", 34)
	add_child(title_label)

	scene_label = Label.new()
	scene_label.position = Vector2(20.0, 72.0)
	scene_label.add_theme_font_size_override("font_size", 22)
	add_child(scene_label)

	hint_label = Label.new()
	hint_label.text = "Next/Prev Scene: select | Enter: run | Reset: reload index"
	hint_label.position = Vector2(20.0, 112.0)
	hint_label.add_theme_font_size_override("font_size", 16)
	add_child(hint_label)

	demo_scenes = GShapes.DemoCatalog.get_index_demos()
	_refresh_scene_text()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Next Scene"):
		if demo_scenes.is_empty():
			return
		index = (index + 1) % demo_scenes.size()
		_refresh_scene_text()
	elif event.is_action_pressed("Previous Scene"):
		if demo_scenes.is_empty():
			return
		index = posmod(index - 1, demo_scenes.size())
		_refresh_scene_text()
	elif event.is_action_pressed("ui_accept"):
		if demo_scenes.is_empty():
			return
		var selected := demo_scenes[index]
		if ResourceLoader.exists(selected):
			get_tree().change_scene_to_file(selected)
		else:
			scene_label.text = "Missing: %s" % selected
	elif event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()


func _refresh_scene_text() -> void:
	if demo_scenes.is_empty():
		scene_label.text = "No demos configured."
		return
	var selected := demo_scenes[index]
	var exists := "ok" if ResourceLoader.exists(selected) else "missing"
	scene_label.text = "%d / %d: %s [%s]" % [index + 1, demo_scenes.size(), selected, exists]

