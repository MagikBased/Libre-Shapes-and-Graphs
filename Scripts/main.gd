extends Node2D

var spawner = Spawner.new()
var circle1 = spawner.spawn_shape("Circle", Vector2(150,50),Color.WHITE)
var circle1_mc = MotionController.new()
var circle2 = spawner.spawn_shape("Circle", Vector2(150,150),Color.WHITE)
var circle2_mc = MotionController.new()
var circle3 = spawner.spawn_shape("Circle", Vector2(150,250),Color.WHITE)
var circle3_mc = MotionController.new()
var circle4 = spawner.spawn_shape("Circle", Vector2(150,350),Color.WHITE)
var circle4_mc = MotionController.new()

var line1 = spawner.spawn_line(Vector2(50,450),Vector2(1050,450))
var line1_mc = LineDraw.new()

func cubic_motion():
	var linearLabel = Label.new()
	linearLabel.text = "Linear"
	linearLabel.position = Vector2(15,40)
	linearLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	linearLabel.modulate = Color.RED
	add_child(linearLabel)

	var cubicInLabel = Label.new()
	cubicInLabel.text = "Cubic In"
	cubicInLabel.position = Vector2(15,140)
	cubicInLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cubicInLabel.modulate = Color.BLUE
	add_child(cubicInLabel)

	var cubicOutLabel = Label.new()
	cubicOutLabel.text = "Cubic Out"
	cubicOutLabel.position = Vector2(15,240)
	cubicOutLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cubicOutLabel.modulate = Color.GREEN
	add_child(cubicOutLabel)

	var cubicInOutLabel = Label.new()
	cubicInOutLabel.text = "Cubic In Out"
	cubicInOutLabel.position = Vector2(15,340)
	cubicInOutLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cubicInOutLabel.modulate = Color.PURPLE
	add_child(cubicInOutLabel)

	add_child(spawner)
	circle1_mc.set_target(circle1)
	add_child(circle1_mc)
	circle2_mc.set_target(circle2)
	add_child(circle2_mc)
	circle3_mc.set_target(circle3)
	add_child(circle3_mc)
	circle4_mc.set_target(circle4)
	add_child(circle4_mc)
	circle1_mc.start_lerp_to(Vector2(1050,50),"Linear",true,true)
	circle2_mc.start_lerp_to(Vector2(1050,150),"CubicIn",true,true)
	circle3_mc.start_lerp_to(Vector2(1050,250),"CubicOut",true,true)
	circle4_mc.start_lerp_to(Vector2(1050,350),"CubicInOut",true,true)
	circle1_mc.start_color_lerp(Color.WHITE, Color.RED,"Linear",true,true)
	circle2_mc.start_color_lerp(Color.WHITE, Color.BLUE,"Linear",true,true)
	circle3_mc.start_color_lerp(Color.WHITE, Color.GREEN,"Linear",true,true)
	circle4_mc.start_color_lerp(Color.WHITE, Color.PURPLE,"Linear",true,true)


func lines():
	#add_child(spawner)
	line1_mc.set_target(line1)
	add_child(line1_mc)
	print("LineMC: " + str(line1_mc))

func _ready():
	cubic_motion()
	lines()

func _process(_delta):
	pass
func _draw():
	pass

func _input(event):
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()

