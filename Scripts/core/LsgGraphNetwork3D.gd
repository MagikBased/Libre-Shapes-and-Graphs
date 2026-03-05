class_name LsgGraphNetwork3D
extends Node3D

var layout_name: StringName = &"ring"
var connection_name: StringName = &"cycle"
var node_count: int = 10
var radius: float = 2.0
var phase: float = 0.0

var node_scale: float = 0.12
var node_color: Color = Color(1.0, 0.68, 0.3, 0.95)
var edge_thickness: float = 0.03
var edge_color: Color = Color(0.36, 0.9, 1.0, 0.8)

var _nodes_mm: MultiMeshInstance3D
var _edge_pool: Array[LsgTubePath3D] = []
var _positions: Array[Vector3] = []


func _ready() -> void:
	_ensure_nodes_mm()
	rebuild()


func rebuild() -> void:
	_positions = _build_positions()
	var edges: Array[Vector2i] = _build_edges(_positions.size())
	_rebuild_nodes(_positions)
	_rebuild_edges(_positions, edges)


func _ensure_nodes_mm() -> void:
	if _nodes_mm != null:
		return
	_nodes_mm = MultiMeshInstance3D.new()
	add_child(_nodes_mm)


func _build_positions() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var count: int = maxi(3, node_count)
	var r: float = maxf(0.1, radius)
	var p: float = phase
	var layout: String = String(layout_name).to_lower()

	if layout == "double_ring":
		var inner: int = int(floor(float(count) * 0.5))
		var outer: int = count - inner
		for i in range(inner):
			var a: float = TAU * float(i) / float(maxi(1, inner)) + p * 0.6
			out.append(Vector3(cos(a) * (r * 0.62), -0.45, sin(a) * (r * 0.62)))
		for j in range(outer):
			var b: float = TAU * float(j) / float(maxi(1, outer)) - p * 0.4
			out.append(Vector3(cos(b) * r, 0.55, sin(b) * r))
		return out

	if layout == "cloud":
		for k in range(count):
			var kk: float = float(k)
			var a2: float = kk * 2.399963 + p * 0.45
			var y: float = lerpf(-0.9, 0.9, float(k) / float(maxi(1, count - 1)))
			var rr: float = r * sqrt(maxf(0.0, 1.0 - y * y * 0.5))
			out.append(Vector3(cos(a2) * rr, y * r * 0.7, sin(a2) * rr))
		return out

	for i2 in range(count):
		var a3: float = TAU * float(i2) / float(count) + p * 0.5
		out.append(Vector3(cos(a3) * r, sin(p + float(i2) * 0.35) * 0.35, sin(a3) * r))
	return out


func _build_edges(count: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if count < 2:
		return out

	var mode: String = String(connection_name).to_lower()
	if mode == "chords":
		for i in range(count):
			out.append(Vector2i(i, (i + 1) % count))
			out.append(Vector2i(i, (i + 2) % count))
		return _dedupe_edges(out)

	if mode == "hub":
		for j in range(1, count):
			out.append(Vector2i(0, j))
		for k in range(count):
			out.append(Vector2i(k, (k + 1) % count))
		return _dedupe_edges(out)

	for i2 in range(count):
		out.append(Vector2i(i2, (i2 + 1) % count))
	return _dedupe_edges(out)


func _dedupe_edges(edges: Array[Vector2i]) -> Array[Vector2i]:
	var seen: Dictionary = {}
	var out: Array[Vector2i] = []
	for e in edges:
		var a: int = mini(e.x, e.y)
		var b: int = maxi(e.x, e.y)
		if a == b:
			continue
		var key: String = "%d_%d" % [a, b]
		if seen.has(key):
			continue
		seen[key] = true
		out.append(Vector2i(a, b))
	return out


func _rebuild_nodes(positions: Array[Vector3]) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mm.mesh = mesh
	mm.instance_count = positions.size()

	var scale_factor: float = maxf(0.001, node_scale)
	for i in range(positions.size()):
		var xf := Transform3D(Basis().scaled(Vector3.ONE * scale_factor), positions[i])
		mm.set_instance_transform(i, xf)
		mm.set_instance_color(i, node_color)

	_nodes_mm.multimesh = mm


func _rebuild_edges(positions: Array[Vector3], edges: Array[Vector2i]) -> void:
	_ensure_edge_pool(edges.size())
	for i in range(_edge_pool.size()):
		var tube: LsgTubePath3D = _edge_pool[i]
		if i >= edges.size():
			tube.visible = false
			continue
		tube.visible = true
		tube.radius = maxf(0.001, edge_thickness)
		tube.path_color = edge_color
		tube.radial_segments = 8
		tube.closed_path = false
		var edge: Vector2i = edges[i]
		var pts: Array[Vector3] = [positions[edge.x], positions[edge.y]]
		tube.set_points(pts)


func _ensure_edge_pool(target_count: int) -> void:
	while _edge_pool.size() < target_count:
		var tube: LsgTubePath3D = GShapes.TubePath3D.new()
		add_child(tube)
		_edge_pool.append(tube)
