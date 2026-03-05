# Demo: ConformalGridParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends GShapesCompatibleScene

var tracker: LsgValueTracker
var grid: LsgConformalGrid2D
var _last_strength: float = -9999.0


func _ready() -> void:
	_create_caption("Phase 6 conformal-grid parity: deformed coordinate grid with animated strength")

	tracker = GShapes.ValueTracker.new(0.15)
	add_child(tracker)

	grid = GShapes.ConformalGrid2D.new()
	grid.position = Vector2(640.0, 360.0)
	grid.mode_name = &"twist"
	grid.major_step = 58.0
	grid.samples_per_line = 48
	grid.strength = tracker.get_value()
	add_child(grid)
	grid.rebuild()
	_last_strength = grid.strength

	play_sequence([
		GShapes.SetValue.new(tracker, 0.65, 1.6, &"smooth"),
		GShapes.SetValue.new(tracker, 0.25, 1.2, &"smooth"),
		GShapes.SetValue.new(tracker, 0.9, 1.2, &"linear"),
	])


func _process(_delta: float) -> void:
	if grid == null or tracker == null:
		return
	var s: float = tracker.get_value()
	if absf(s - _last_strength) >= 0.03:
		grid.strength = s
		grid.rebuild()
		_last_strength = s


func _create_caption(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	add_child(label)

