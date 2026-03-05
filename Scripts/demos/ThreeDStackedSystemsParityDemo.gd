# Demo: ThreeDStackedSystemsParityDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var axes: LsgAxes3D
var stacked_rings: Array = []
var ring_roots: Array[Node3D] = []
var markers: Array[Node3D] = []
var time_accum: float = 0.0


func _ready() -> void:
	super._ready()
	target_point = Vector3(0.0, 0.4, 0.0)
	set_orbit_pose(0.34, -0.3, 12.4)
	set_camera_fov(70.0)

	axes = GShapes.Axes3D.new()
	axes.axis_length = 3.8
	axes.axis_thickness = 0.026
	axes.tip_radius = 0.08
	axes.tip_height = 0.22
	axes.show_negative_axes = true
	add_child(axes)

	_create_stacked_rings()
	_create_markers()
	_create_overlay()
	_run_timeline()
	_frame_all()


func _process(delta: float) -> void:
	time_accum += delta
	axes.rotation.y = sin(time_accum * 0.3) * 0.08
	for i in range(ring_roots.size()):
		var root: Node3D = ring_roots[i]
		var dir: float = 1.0 if i % 2 == 0 else -1.0
		root.rotate_y(delta * (0.28 + float(i) * 0.07) * dir)
	for i in range(stacked_rings.size()):
		var ring: Array = stacked_rings[i]
		var band_phase: float = time_accum * (0.9 + float(i) * 0.12)
		for j in range(ring.size()):
			var node: Node3D = ring[j]
			node.position.y = sin(band_phase + float(j) * 0.45) * 0.16
	for i in range(markers.size()):
		var marker: Node3D = markers[i]
		marker.rotation.y += delta * 1.0


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_1:
			_focus_level(0)
		elif key.keycode == KEY_2:
			_focus_level(1)
		elif key.keycode == KEY_3:
			_focus_level(2)
		elif key.keycode == KEY_0:
			_frame_all()


func _create_stacked_rings() -> void:
	for level in range(3):
		var ring_root := Node3D.new()
		ring_root.position = Vector3.ZERO
		add_child(ring_root)
		ring_roots.append(ring_root)

		var ring_nodes: Array = []
		var y_base: float = -1.8 + float(level) * 1.2
		var radius: float = 1.2 + float(level) * 0.7
		var count: int = 6 + level * 2
		for i in range(count):
			var body := MeshInstance3D.new()
			if (i + level) % 2 == 0:
				var sphere := SphereMesh.new()
				sphere.radius = 0.16 + float(level) * 0.03
				sphere.height = sphere.radius * 2.0
				body.mesh = sphere
			else:
				var box := BoxMesh.new()
				var s: float = 0.26 + float(level) * 0.05
				box.size = Vector3(s, s, s)
				body.mesh = box
			var angle: float = TAU * float(i) / float(count)
			body.position = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color.from_hsv(0.08 + float(level) * 0.22 + float(i) * 0.03, 0.68, 0.95)
			mat.roughness = 0.43
			body.material_override = mat
			ring_root.add_child(body)
			ring_nodes.append(body)
		ring_root.position.y = y_base
		stacked_rings.append(ring_nodes)


func _create_markers() -> void:
	var positions: Array[Vector3] = [
		Vector3(-3.2, -1.8, 0.0),
		Vector3(0.0, -0.6, -3.0),
		Vector3(3.2, 0.6, 0.0),
	]
	for i in range(positions.size()):
		var torus := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.32
		cylinder.bottom_radius = 0.32
		cylinder.height = 0.06
		torus.mesh = cylinder
		torus.position = positions[i]
		torus.rotate_x(PI * 0.5)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.92, 0.9, 0.45).darkened(float(i) * 0.12)
		mat.roughness = 0.35
		torus.material_override = mat
		add_child(torus)
		markers.append(torus)


func _run_timeline() -> void:
	var chain: Tween = create_tween()
	chain.set_parallel(false)
	chain.tween_interval(0.25)
	chain.tween_callback(func(): _focus_level(0))
	chain.tween_interval(1.0)
	chain.tween_callback(func(): _focus_level(1))
	chain.tween_interval(1.0)
	chain.tween_callback(func(): _focus_level(2))
	chain.tween_interval(1.0)
	chain.tween_callback(func():
		for ring in stacked_rings:
			GShapes.Effects3D.staggered_pulse(self, ring, 0.03, 1.2, 0.4)
	)
	chain.tween_interval(0.85)
	chain.tween_callback(func(): _frame_all())


func _focus_level(level: int) -> void:
	if level < 0 or level >= stacked_rings.size():
		return
	var nodes: Array = []
	nodes.append(ring_roots[level])
	for n in stacked_rings[level]:
		nodes.append(n)
	tween_frame_to_nodes(nodes, 1.3, 0.75)
	tween_fov_to(60.0, 0.75)


func _frame_all() -> void:
	var nodes: Array = [axes]
	for root in ring_roots:
		nodes.append(root)
	for marker in markers:
		nodes.append(marker)
	tween_frame_to_nodes(nodes, 1.22, 0.85)
	tween_fov_to(70.0, 0.85)


func _create_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D stacked-systems parity: 1/2/3 focus levels, 0 all | RMB orbit, MMB pan, wheel zoom, R reset"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)
