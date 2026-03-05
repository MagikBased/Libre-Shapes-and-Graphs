# Demo: Surface3DDemo
# Expected behavior: See PlansAndCopy/DEMO_NOTES.md

extends Lsg3DScene

var surface: LsgSurfaceMesh3D


func _ready() -> void:
	super._ready()
	target_point = Vector3.ZERO
	set_orbit_pose(0.0, -0.25, 8.0)

	surface = GShapes.SurfaceMesh3D.new()
	surface.surface_name = &"wave"
	surface.x_steps = 64
	surface.z_steps = 64
	add_child(surface)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.65, 1.0)
	mat.metallic = 0.05
	mat.roughness = 0.35
	surface.material_override = mat

	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "3D demo: hold RMB + drag to orbit, mouse wheel to zoom"
	label.position = Vector2(16.0, 12.0)
	label.modulate = Color(0.9, 0.95, 1.0)
	layer.add_child(label)


func _process(delta: float) -> void:
	surface.rotation.y += delta * 0.35
