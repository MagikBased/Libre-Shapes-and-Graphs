# Demo: FlowParticlesParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: GShapesValueTracker
var particles: GShapesFlowParticles2D


func _ready() -> void:
	_create_caption("Phase 6 flow-particles parity: field-driven particles with animated strength")

	tracker = GShapes.ValueTracker.new(0.35)
	add_child(tracker)

	particles = GShapes.FlowParticles2D.new()
	particles.position = Vector2(640.0, 360.0)
	particles.field_name = &"swirl"
	particles.strength = tracker.get_value()
	particles.particle_count = 170
	particles.step_size = 0.011
	particles.particle_radius = 2.0
	particles.particle_color = Color(0.8, 0.94, 1.0, 0.74)
	add_child(particles)
	particles.reset_particles()

	play_sequence([
		GShapes.SetValue.new(tracker, 0.95, 1.7, &"smooth"),
		GShapes.SetValue.new(tracker, 0.25, 1.3, &"smooth"),
		GShapes.SetValue.new(tracker, 1.2, 1.2, &"linear"),
	])


func _process(_delta: float) -> void:
	if particles == null or tracker == null:
		return
	particles.strength = tracker.get_value()


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)




