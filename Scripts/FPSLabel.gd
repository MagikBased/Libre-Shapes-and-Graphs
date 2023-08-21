extends Label

@onready var fps_label = $"."

func _process(_delta):
	fps_label.text = str(int(Engine.get_frames_per_second())) + " FPS"
