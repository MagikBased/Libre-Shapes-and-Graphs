extends Node2D

const CHECK_PATHS: Array[String] = [
	"res://addons/gshapes/Scripts/core/GShapes.gd",
	"res://addons/gshapes/Scripts/core/GraphAxes2D.gd",
	"res://addons/gshapes/Scripts/core/GShapesValueTracker.gd",
	"res://addons/gshapes/Scripts/core/GShapesWait.gd",
	"res://addons/gshapes/Scripts/core/GShapesAnimationGroup.gd",
	"res://addons/gshapes/Scripts/core/GShapesSequence.gd",
	"res://addons/gshapes/Scripts/core/GShapesLaggedGroup.gd",
	"res://addons/gshapes/Scripts/core/GShapesCompatibleScene.gd"
]

func _ready() -> void:
	var failures: Array[String] = []
	for path in CHECK_PATHS:
		var script_res: Variant = load(path)
		if script_res == null:
			failures.append("load_failed: %s" % path)

	var wait_script: Variant = load("res://addons/gshapes/Scripts/core/GShapesWait.gd")
	var group_script: Variant = load("res://addons/gshapes/Scripts/core/GShapesAnimationGroup.gd")
	var sequence_script: Variant = load("res://addons/gshapes/Scripts/core/GShapesSequence.gd")
	var lagged_script: Variant = load("res://addons/gshapes/Scripts/core/GShapesLaggedGroup.gd")
	if wait_script != null and group_script != null and sequence_script != null and lagged_script != null:
		var wait_anim: Variant = (wait_script as GDScript).new()
		if wait_anim == null:
			failures.append("new_failed: GShapesWait")
		else:
			var group_anim: Variant = (group_script as GDScript).new([wait_anim])
			if group_anim == null:
				failures.append("new_failed: GShapesAnimationGroup")
			var sequence_anim: Variant = (sequence_script as GDScript).new([wait_anim])
			if sequence_anim == null:
				failures.append("new_failed: GShapesSequence")
			var lagged_anim: Variant = (lagged_script as GDScript).new([wait_anim], 0.15)
			if lagged_anim == null:
				failures.append("new_failed: GShapesLaggedGroup")

	var result_label := Label.new()
	result_label.position = Vector2(16.0, 16.0)
	result_label.add_theme_font_size_override("font_size", 24)
	if failures.is_empty():
		result_label.text = "GShapes addon smoke: PASS"
		print("[GShapesAddonSmoke] PASS")
	else:
		result_label.text = "GShapes addon smoke: FAIL (%d)" % failures.size()
		push_error("[GShapesAddonSmoke] FAIL")
		for issue in failures:
			push_error("[GShapesAddonSmoke] %s" % issue)
	add_child(result_label)