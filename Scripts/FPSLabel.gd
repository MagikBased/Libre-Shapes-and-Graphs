extends Label


# Reference to the label
@onready var fps_label = $"."

func _process(_delta):
	# Display the current FPS rounded to no decimal places.
	fps_label.text = str(int(Engine.get_frames_per_second())) + " FPS"
