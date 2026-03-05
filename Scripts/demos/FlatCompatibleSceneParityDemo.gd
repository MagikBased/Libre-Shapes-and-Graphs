# Demo: FlatCompatibleSceneParityDemo
# Expected behavior: LsgCompatibleScene-style timeline API running inside flat 2D-on-3D scene mode.

extends GShapesFlatCompatibleScene3D

var circle: Circle
var square: Rectangle
var connector: Line


func _ready() -> void:
	canvas_size = Vector2i(1280, 720)
	pixels_per_unit = 160.0
	orthographic_size = 4.6
	use_orthographic_projection = true
	super._ready()

	set_orbit_pose(0.04, -0.15, 9.0)
	frame_canvas(1.1)

	_build_content()
	_build_overlay()
	_run_timeline()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F:
			frame_canvas(1.1)
		elif key.keycode == KEY_P:
			set_projection_mode_orthographic(not use_orthographic_projection)


func _build_content() -> void:
	circle = Circle.new()
	circle.size = Vector2(90.0, 90.0)
	circle.color = Color(0.33, 0.86, 1.0)
	circle.position = Vector2(210.0, 360.0)
	add_flat_child(circle)

	square = Rectangle.new()
	square.size = Vector2(110.0, 110.0)
	square.color = Color(1.0, 0.63, 0.25)
	square.position = Vector2(1020.0, 360.0)
	add_flat_child(square)

	connector = Line.new()
	connector.start_point = circle.position
	connector.end_point = square.position
	connector.line_type = Line.LineType.LINEAR
	connector.stroke_width = 4.0
	connector.color = Color(0.95, 0.9, 0.7)
	add_flat_child(connector)


func _run_timeline() -> void:
	play(GShapes.ShowCreation.new(connector, 0.7, &"linear"))
	play_lagged([
		GShapes.GrowFromCenter.new(circle, 0.6, &"smooth"),
		GShapes.GrowFromCenter.new(square, 0.6, &"smooth"),
	], 0.2, 1.1, &"smooth")
	wait(0.2)
	play([
		circle.animate.shift(Vector2(240.0, -120.0)).set_color(Color(0.58, 1.0, 0.72)).set_run_time(1.0),
		square.animate.shift(Vector2(-250.0, 140.0)).set_color(Color(1.0, 0.47, 0.58)).set_run_time(1.0),
	])
	wait(0.1)
	play_map([circle, square], func(node: Node2D):
		return (node as LsgObject2D).animate.rotate_to(node.rotation + 0.5).set_run_time(0.7)
	)
	wait(0.1)
	play(GShapes.Wiggle.new(circle, 0.8, &"smooth"))
	play(GShapes.Wiggle.new(square, 0.8, &"smooth"))


func _process(_delta: float) -> void:
	if connector == null or circle == null or square == null:
		return
	connector.set_endpoints(circle.position, square.position)


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = "Flat compatible scene parity: play/wait/group/map in flat 2D-on-3D mode | RMB orbit, MMB pan, wheel zoom, R reset, F frame, P projection"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)

