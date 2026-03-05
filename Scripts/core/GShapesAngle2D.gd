class_name GShapesAngle2D
extends GShapesObject2D

var vertex_node: Node2D
var ray_a_node: Node2D
var ray_b_node: Node2D
var vertex_point: Vector2 = Vector2.ZERO
var ray_a_point: Vector2 = Vector2.RIGHT
var ray_b_point: Vector2 = Vector2.DOWN

var radius: float = 56.0
var stroke_width: float = 3.0
var clockwise: bool = false
var follow_nodes: bool = true
var show_right_angle_elbow: bool = false
var elbow_scale: float = 0.32

var _start_angle: float = 0.0
var _sweep_angle: float = PI * 0.5
var _vertex_world: Vector2 = Vector2.ZERO


func _init(
	p_vertex_node: Node2D = null,
	p_ray_a_node: Node2D = null,
	p_ray_b_node: Node2D = null
) -> void:
	vertex_node = p_vertex_node
	ray_a_node = p_ray_a_node
	ray_b_node = p_ray_b_node


func _ready() -> void:
	update_geometry()


func _process(delta: float) -> void:
	super._process(delta)
	if follow_nodes:
		update_geometry()


func set_nodes(p_vertex_node: Node2D, p_ray_a_node: Node2D, p_ray_b_node: Node2D) -> void:
	vertex_node = p_vertex_node
	ray_a_node = p_ray_a_node
	ray_b_node = p_ray_b_node
	update_geometry()


func set_points(p_vertex: Vector2, p_a: Vector2, p_b: Vector2) -> void:
	vertex_point = p_vertex
	ray_a_point = p_a
	ray_b_point = p_b
	update_geometry()


func update_geometry() -> void:
	var v: Vector2 = _resolve_vertex()
	var a: Vector2 = _resolve_a()
	var b: Vector2 = _resolve_b()
	var va: Vector2 = a - v
	var vb: Vector2 = b - v
	if va.length_squared() <= 0.000001 or vb.length_squared() <= 0.000001:
		return

	_vertex_world = v
	_start_angle = va.angle()
	_sweep_angle = _signed_angle(va, vb)
	if clockwise and _sweep_angle > 0.0:
		_sweep_angle -= TAU
	elif not clockwise and _sweep_angle < 0.0:
		_sweep_angle += TAU
	queue_redraw()


func get_label_anchor(distance: float = 18.0) -> Vector2:
	var mid: float = _start_angle + _sweep_angle * 0.5
	return _vertex_world + Vector2(cos(mid), sin(mid)) * (radius + distance)


func _draw() -> void:
	var local_center: Vector2 = to_local(_vertex_world)
	var step_count: int = maxi(6, int(ceil(absf(_sweep_angle) * 16.0)))
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(step_count + 1):
		var t: float = float(i) / float(step_count)
		var ang: float = _start_angle + _sweep_angle * t
		points.append(local_center + Vector2(cos(ang), sin(ang)) * radius)

	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, stroke_width)

	if show_right_angle_elbow and absf(absf(_sweep_angle) - PI * 0.5) <= 0.06:
		var u0: Vector2 = Vector2(cos(_start_angle), sin(_start_angle))
		var u1: Vector2 = Vector2(cos(_start_angle + _sweep_angle), sin(_start_angle + _sweep_angle))
		var d: float = radius * elbow_scale
		var p0: Vector2 = local_center + u0 * d
		var p1: Vector2 = p0 + u1 * d
		var p2: Vector2 = local_center + u1 * d
		draw_line(p0, p1, color, stroke_width)
		draw_line(p1, p2, color, stroke_width)


func _resolve_vertex() -> Vector2:
	if vertex_node != null and is_instance_valid(vertex_node):
		return vertex_node.global_position
	return vertex_point


func _resolve_a() -> Vector2:
	if ray_a_node != null and is_instance_valid(ray_a_node):
		return ray_a_node.global_position
	return ray_a_point


func _resolve_b() -> Vector2:
	if ray_b_node != null and is_instance_valid(ray_b_node):
		return ray_b_node.global_position
	return ray_b_point


func _signed_angle(a: Vector2, b: Vector2) -> float:
	var det: float = a.x * b.y - a.y * b.x
	var dot: float = a.dot(b)
	return atan2(det, dot)



