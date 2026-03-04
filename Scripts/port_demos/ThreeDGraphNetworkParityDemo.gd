# Demo: ThreeDGraphNetworkParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Port3DScene

var axes: PortAxes3D
var graph_net: PortGraphNetwork3D
var time_accum: float = 0.0
var layout_index: int = 0
var connection_index: int = 0
var layouts: Array[StringName] = [&"ring", &"double_ring", &"cloud"]
var connections: Array[StringName] = [&"cycle", &"chords", &"hub"]


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.35, -0.22, 12.0)
	set_camera_fov(69.0)

	axes = PortAxes3D.new()
	axes.axis_length = 4.0
	axes.axis_thickness = 0.024
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	graph_net = PortGraphNetwork3D.new()
	graph_net.layout_name = layouts[layout_index]
	graph_net.connection_name = connections[connection_index]
	graph_net.node_count = 12
	graph_net.radius = 2.2
	graph_net.node_scale = 0.13
	graph_net.edge_thickness = 0.028
	add_child(graph_net)

	_create_overlay()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.16) * 0.08
	graph_net.phase = time_accum
	if (int(floor(time_accum * 0.55)) % 2) == 0:
		graph_net.rebuild()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_SPACE:
			_cycle_connection()
		elif key.keycode == KEY_1:
			_set_layout(0)
		elif key.keycode == KEY_2:
			_set_layout(1)
		elif key.keycode == KEY_3:
			_set_layout(2)
		elif key.keycode == KEY_F:
			_frame_all()


func _cycle_connection() -> void:
	if connections.is_empty():
		return
	connection_index = (connection_index + 1) % connections.size()
	_apply_modes()


func _set_layout(idx: int) -> void:
	if idx < 0 or idx >= layouts.size():
		return
	layout_index = idx
	_apply_modes()


func _apply_modes() -> void:
	graph_net.layout_name = layouts[layout_index]
	graph_net.connection_name = connections[connection_index]
	graph_net.rebuild()


func _frame_all() -> void:
	var nodes: Array = [axes, graph_net]
	tween_frame_to_nodes(nodes, 1.2, 0.84)
	tween_fov_to(69.0, 0.84)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D graph-network parity: PortGraphNetwork3D | Space connection, 1/2/3 layout, RMB orbit, MMB pan, wheel zoom, R reset, F reframe"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
