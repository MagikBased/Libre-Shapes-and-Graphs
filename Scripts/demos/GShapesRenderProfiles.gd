class_name GShapesRenderProfiles
extends RefCounted

const PROFILES := {
	"draft": {
		"label": "Draft",
		"width": 1280,
		"height": 720,
		"fps": 30,
		"bitrate": "8M",
		"duration_seconds": 8.0,
	},
	"review": {
		"label": "Review",
		"width": 1920,
		"height": 1080,
		"fps": 60,
		"bitrate": "16M",
		"duration_seconds": 12.0,
	},
	"master": {
		"label": "Master",
		"width": 2560,
		"height": 1440,
		"fps": 60,
		"bitrate": "28M",
		"duration_seconds": 15.0,
	},
}


static func get_profile_names() -> PackedStringArray:
	var names := PackedStringArray()
	for key in PROFILES.keys():
		names.append(str(key))
	names.sort()
	return names


static func get_profile(name: String) -> Dictionary:
	if PROFILES.has(name):
		return PROFILES[name]
	return PROFILES["review"]


static func build_output_basename(scene_path: String, profile_name: String) -> String:
	var scene_name := scene_path.get_file().trim_suffix(".tscn")
	return "%s__%s" % [scene_name, profile_name]



