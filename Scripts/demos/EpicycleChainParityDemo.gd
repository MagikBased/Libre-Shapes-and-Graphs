# Demo: EpicycleChainParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: GShapesValueTracker
var chain: GShapesEpicycleChain2D
var tracer: GShapesTracedPath2D
var dot: Circle


func _ready() -> void:
	_create_caption("Phase 6 epicycle-chain parity: rotating harmonic vectors with traced endpoint")

	tracker = GShapes.ValueTracker.new(0.0)
	add_child(tracker)

	chain = GShapes.EpicycleChain2D.new()
	chain.position = Vector2(640.0, 360.0)
	chain.scale_factor = 96.0
	add_child(chain)

	dot = Circle.new()
	dot.size = Vector2(10.0, 10.0)
	dot.color = Color(1.0, 0.72, 0.35, 0.95)
	add_child(dot)
	dot.add_updater(func(target: GShapesObject2D, _delta: float) -> void:
		var t: float = tracker.get_value()
		chain.set_time(t)
		(target as Node2D).position = chain.position + chain.endpoint_local_at(t)
	)

	tracer = GShapes.TracedPath2D.new()
	tracer.set_point_callable(func() -> Variant:
		return dot.position
	)
	tracer.local_space = false
	tracer.min_distance = 1.6
	tracer.max_points = 1800
	tracer.stroke_width = 2.4
	tracer.color = Color(0.55, 0.95, 1.0, 0.85)
	add_child(tracer)

	play(GShapes.FadeIn.new(chain, 0.4, &"smooth"))
	play(GShapes.FadeIn.new(dot, 0.25, &"smooth"))
	wait(0.15)
	play_sequence([
		GShapes.SetValue.new(tracker, TAU * 0.9, 1.45, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 1.75, 1.35, &"smooth"),
		GShapes.SetValue.new(tracker, TAU * 2.4, 1.35, &"linear"),
	])


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




