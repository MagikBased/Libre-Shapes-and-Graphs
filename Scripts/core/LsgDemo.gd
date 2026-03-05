extends Node2D

var runner: LsgSceneRunner
var demo_circle: Circle


func _ready() -> void:
	runner = GShapes.SceneRunner.new()
	add_child(runner)

	demo_circle = Circle.new()
	demo_circle.size = Vector2(60.0, 60.0)
	demo_circle.color = Color.WHITE
	demo_circle.position = Vector2(160.0, 280.0)
	add_child(demo_circle)

	_create_caption("Demo: move + color with timeline rate functions")

	runner.play(
		GShapes.MoveTo.new(
			demo_circle,
			Vector2(1020.0, 280.0),
			3.0,
			&"there_and_back"
		)
	)
	runner.play(
		GShapes.FadeToColor.new(
			demo_circle,
			Color.WHITE,
			Color.CORNFLOWER_BLUE,
			3.0,
			&"smooth"
		)
	)


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.85, 0.9, 1.0)
	add_child(label)
