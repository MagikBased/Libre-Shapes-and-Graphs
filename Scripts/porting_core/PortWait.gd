class_name PortWait
extends PortAnimation


func _init(p_run_time: float = 1.0) -> void:
	super(null, p_run_time, &"linear")


func interpolate(_alpha: float) -> void:
	pass
