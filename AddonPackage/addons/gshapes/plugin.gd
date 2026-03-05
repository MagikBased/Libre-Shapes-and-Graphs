@tool
extends EditorPlugin

func _enter_tree() -> void:
	# First packaging pass: runtime scripts are provided under addons/gshapes/Scripts.
	pass

func _exit_tree() -> void:
	pass