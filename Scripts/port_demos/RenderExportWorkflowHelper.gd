# Demo: RenderExportWorkflowHelper
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Node2D

var demo_scenes: Array[String] = []
var scene_index: int = 0

var profile_names: PackedStringArray = PackedStringArray()
var profile_index: int = 0

var title_label: Label
var selected_scene_label: Label
var selected_profile_label: Label
var output_label: Label
var checklist_label: Label


func _ready() -> void:
	title_label = Label.new()
	title_label.text = "Render/Export Workflow Helper"
	title_label.position = Vector2(20.0, 16.0)
	title_label.add_theme_font_size_override("font_size", 30)
	add_child(title_label)

	selected_scene_label = Label.new()
	selected_scene_label.position = Vector2(20.0, 64.0)
	selected_scene_label.add_theme_font_size_override("font_size", 18)
	add_child(selected_scene_label)

	selected_profile_label = Label.new()
	selected_profile_label.position = Vector2(20.0, 92.0)
	selected_profile_label.add_theme_font_size_override("font_size", 18)
	add_child(selected_profile_label)

	output_label = Label.new()
	output_label.position = Vector2(20.0, 128.0)
	output_label.add_theme_font_size_override("font_size", 16)
	add_child(output_label)

	checklist_label = Label.new()
	checklist_label.position = Vector2(20.0, 190.0)
	checklist_label.add_theme_font_size_override("font_size", 14)
	checklist_label.text = "Controls: Next/Prev Scene=scene | Enter=profile | Reset=open selected scene"
	add_child(checklist_label)

	demo_scenes = PortDemoCatalog.get_visual_demos()
	profile_names = PortRenderProfiles.get_profile_names()
	_refresh_labels()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Next Scene"):
		scene_index = (scene_index + 1) % max(1, demo_scenes.size())
		_refresh_labels()
	elif event.is_action_pressed("Previous Scene"):
		scene_index = posmod(scene_index - 1, max(1, demo_scenes.size()))
		_refresh_labels()
	elif event.is_action_pressed("ui_accept"):
		profile_index = (profile_index + 1) % max(1, profile_names.size())
		_refresh_labels()
	elif event.is_action_pressed("Reset"):
		if demo_scenes.is_empty():
			return
		var selected := demo_scenes[scene_index]
		if ResourceLoader.exists(selected):
			get_tree().change_scene_to_file(selected)


func _refresh_labels() -> void:
	if demo_scenes.is_empty() or profile_names.is_empty():
		selected_scene_label.text = "No scenes/profiles configured."
		selected_profile_label.text = ""
		output_label.text = ""
		return

	var scene_path := demo_scenes[scene_index]
	var profile_name := profile_names[profile_index]
	var profile := PortRenderProfiles.get_profile(profile_name)
	var base_name := PortRenderProfiles.build_output_basename(scene_path, profile_name)

	selected_scene_label.text = "Scene: %s" % scene_path
	selected_profile_label.text = "Profile: %s | %dx%d @ %dfps | bitrate=%s | duration=%.1fs" % [
		profile_name,
		int(profile.get("width", 1920)),
		int(profile.get("height", 1080)),
		int(profile.get("fps", 60)),
		str(profile.get("bitrate", "16M")),
		float(profile.get("duration_seconds", 10.0)),
	]
	output_label.text = "Output basename: %s\nConvention: captures/%s.mp4" % [base_name, base_name]
