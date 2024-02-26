extends Node2D

onready var road_block = preload("res://src/scenes/runway/runway_objects/road_block.tscn")
onready var line = preload("res://src/scripts/Line.gd")


var WIDTH = OS.get_screen_size().x
var HEIGHT = OS.get_screen_size().y



export var RUNWAY_LENGTH = 2800
export var RUNWAY_WIDTH = 2500
export var SEGMENT_LENGTH = 400
export var CAMERA_DEPTH = 0.84

export var BORDER:Color
export var RUNWAY:Color
export var DIVID_LINE:Color
export var GRAMME:Color
export var STRIPED_RUNWAY:Color
export var STRIPED_BORDER:Color
export var STRIPED_DIVID_LINE:Color
export var STRIPED_GRAMME:Color

var NEW_BORDER:Color
var NEW_RUNWAY:Color
var NEW_DIVID_LINE:Color
var NEW_GRAMME:Color

var lines = []

var current_position = 0
var lines_length

var camera_x = 0

var up_is_pressed = false

var controller_draw_sprites = true

var speed = 0
var max_speed = 720
var max_speed_meth = 1080

var centrifugal = 0.00009

var accumulate_curve = 0
var distance_x = 0

enum State {
	tree_01 = 1, 
	road_block = 5
}

var current_state = State.tree_01

var play_curve = 0

var skyline

var hud_time
var hud_return
var timer

var quantity_return = 0

var instance_timer

var instance_timer_step

var start_time:bool = false
var winner:bool = false

var speedometer_hand

var paused:bool = false
var pause_overlay

signal has_finished

var road_block_pool
func _ready():
	randomize()
	road_block_pool = []
	for _i in range(9):
		road_block_pool.append(road_block.instance())
		_i += 1

	audio_manager.stop_sound()
	speedometer_hand = get_node("../SpeedometerScale/SpeedometerHand")
	pause_overlay = get_node("../user_menu/pause")
	hud_return = get_node("../hud_return/return")
		
	$car.position = Vector2(960, 870)
	skyline = get_node("../skyline/Sprite")
	
	set_process_input(true)
	init()
	

func _process(_delta):
	
	
	
	var speed_percent = speed / 500
	
	speedometer_hand.rotation_degrees = speed / 4

	controller_inputs()
	controller_curve(speed_percent)
	controller_position()
	
	update()
	
	
func _draw():
	hud_return.text = "Score:  " + str(current_position / 1000)
	if quantity_return == 3:
		speed = 360
		winner = true

	if winner:
		emit_signal("has_finished")
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://src/scenes/screens/winner.tscn")
		
		
		
	if current_position > RUNWAY_LENGTH && not start_time:
		start_time = true
		$music.play()
	

	
	if $car.position.x < 160:
		$car/body/AnimatedSprite.play("curve_right")
		speed = 250
		
	elif $car.position.x > 1760:
		$car/body/AnimatedSprite.play("curve_left")
		speed = 250
		
	var start_point = (current_position / SEGMENT_LENGTH)
	var cam_horizontal = (1800 + lines[start_point].get_world_y())
	var max_y = HEIGHT
	
	accumulate_curve  = 0
	distance_x = 0
	
	controller_skyline(start_point)
	
	for n in range(start_point, start_point + 300):
	
		var current_line = lines[n % lines_length]
	
		var car_position_x = $car.position.x - 960
		var line_offset = start_point * SEGMENT_LENGTH - (lines_length * SEGMENT_LENGTH if n >= lines_length else 0)

		current_line.screen_coordinates(
			car_position_x - accumulate_curve,
			cam_horizontal,
			line_offset,
			CAMERA_DEPTH,
			RUNWAY_WIDTH,
			WIDTH,
			HEIGHT
		)

		var previous_line = lines[(n - 1) % lines_length]

		accumulate_curve += distance_x
		distance_x += current_line.get_curve()
		
		current_line.set_clip(max_y)
		
		var currY = current_line.get_screen_y()
		var currX = current_line.get_screen_x()
		var currW = current_line.get_screen_w()
		
		if (currY >= max_y): continue
		max_y = currY
		
		var y = previous_line.get_screen_y()
		var x = previous_line.get_screen_x()
		var w = previous_line.get_screen_w()

		render_polygon(current_line.get_color_gramme(), 0, y, WIDTH, 0, currY, WIDTH)
		render_polygon(current_line.get_color_border(), x, y, w * 1.1, currX, currY, currW * 1.1)
		render_polygon(current_line.get_color_runway(), x, y, w, currX, currY, currW)
		render_polygon(current_line.get_color_divid_line(), x, y, w * 0.02, currX, currY, currW * 0.02)
	
	draw_sprites()
	update_position_sprites(start_point)
	

func init():
	for index in range(RUNWAY_LENGTH):
		var structure_line = line.Line.new()
		lines.push_back(structure_line)
		add_colors(index)
		lines[index].set_world_z(index * SEGMENT_LENGTH)
		controller_runway(index)
	lines_length = lines.size()
	set_process(true)
	
func _input(event):
	if event.is_action_pressed("ui_up"):
		up_is_pressed = true
	elif event.is_action_released("ui_up"):
		up_is_pressed = false

	if event.is_action_pressed("pause") && !paused:
		pause_overlay.show()
		set_process(false)
		$music.stream_paused = true
		paused = true
	elif event.is_action_pressed("pause") && paused:
		set_process(true)
		pause_overlay.hide()
		$music.stream_paused = false
		paused = false
	



func render_polygon(color, x1, y1, w1, x2, y2, w2):
	var point = [
		Vector2(int(x1 - w1), int(y1)),
		Vector2(int(x2 - w2), int(y2)),
		Vector2(int(x2 + w2), int(y2)),
		Vector2(int(x1 + w1), int(y1))
	]
	var colors = PoolColorArray([color, color, color, color, color])
	draw_primitive(PoolVector2Array(point), colors, PoolVector2Array([]))


func controller_skyline(start_point):
	if speed > 500:
		skyline.position -= Vector2(lines[start_point].get_curve() * 1, 0)
	elif speed < -500:
		skyline.position += Vector2(lines[start_point].get_curve() * 1, 0)
	

func draw_sprites():
	if controller_draw_sprites:
		for i in range(lines_length):
			var current = lines[i]
			if current.get_sprite():
				set_state_sprite(current.get_name_sprite())
				var sprite = current.run_sprite(40, 1)
				if current_state == State.road_block && sprite.get_parent() != self:
					add_child(sprite)
	controller_draw_sprites = false

func update_position_sprites(start_point):
	var aux = start_point + 300
	while aux > start_point:
		var current = lines[aux % lines_length]

		if current.get_sprite():
			set_state_sprite(current.get_name_sprite())

			if current_state == State.road_block:
				current.run_sprite(40, 1)
		aux -= 1


func set_state_sprite(state):
	current_state = state


func controller_position():
	while current_position >= (lines_length * SEGMENT_LENGTH):
		quantity_return += 1
		current_position -= (lines_length * SEGMENT_LENGTH)
		
	while current_position < 0:
		current_position += (lines_length * SEGMENT_LENGTH)


func controller_inputs():
	
	if up_is_pressed:
		
		if Input.is_action_pressed("ui_right"):
			
			$car.position.x += 25
			if [accumulate_curve,speed] > [100000,500]:
				$car/body/AnimatedSprite.play("slip_right")
				$car/body/AnimationCollision.play("animation_slip_right")
			else:
				$car/body/AnimatedSprite.play("curve_right")
				$car/body/AnimationCollision.play("right")
				play_curve += 1
			
		elif Input.is_action_pressed("ui_left"):
			
			$car.position.x -= 25
			if [accumulate_curve,speed] < [-100000,500]:
				$car/body/AnimatedSprite.play("slip_left")
				$car/body/AnimationCollision.play("animation_slip_left")
			else:
				$car/body/AnimatedSprite.play("curve_left")
				$car/body/AnimationCollision.play("left")
				play_curve -= 1
		else:
			$car/body/AnimatedSprite.play("idle")
			$car/body/AnimationCollision.play("idle")

		speed += 5
		
	else:
		$car/body/AnimatedSprite.play("idle")
		$car/body/AnimationCollision.play("idle")
		speed -= 5
	
	
	speed = clamp(speed, 0, max_speed)
	current_position += speed
	

func controller_curve(speed_percent):
	if accumulate_curve > 10000:
		$car.position.x -= (speed_percent * accumulate_curve * centrifugal)
		
	if accumulate_curve < -10000:
		$car.position.x -= (speed_percent * (accumulate_curve / 2) * centrifugal)
		
	camera_x = clamp(camera_x, -4000, 4000)
	
	$car.position.x = clamp($car.position.x, 60, WIDTH - 60)


func add_colors(index):
	#Set red border size
	if (index / 3) % 2:
		lines[index].set_color_border(BORDER)
		lines[index].set_color_runway(RUNWAY)
	else:
		lines[index].set_color_border(STRIPED_BORDER)
		lines[index].set_color_runway(STRIPED_RUNWAY)
		
	#Set divide line gap size
	if (index / 9) % 2:
		lines[index].set_color_divid_line(DIVID_LINE)
		lines[index].set_color_gramme(GRAMME)
	else:
		lines[index].set_color_divid_line(STRIPED_DIVID_LINE)
		lines[index].set_color_gramme(STRIPED_GRAMME)
	
	if index > 10 && index < 15:
		lines[index].set_color_runway(Color(204, 204, 204))
		lines[index].set_color_divid_line(Color(204, 204, 204))
	
func generate_curve():
	randomize()
	#Generate float from -10 to 10
	return rand_range(-7, 7)

var curves = {
	CURVE_01 = generate_curve(),
	CURVE_02 = generate_curve(),
	CURVE_03 = generate_curve(),
	CURVE_04 = generate_curve(),
	CURVE_05 = generate_curve(),

}
var curve_conditions = [
	{"start": 150, "end": 250, "curve": curves.CURVE_01},
	{"start": 250, "end": 350, "curve": curves.CURVE_02},
	{"start": 350, "end": 550, "curve": curves.CURVE_04},
	{"start": 550, "end": 650, "curve": curves.CURVE_05},
	{"start": 650, "end": 1000, "curve": -curves.CURVE_03},
	{"start": 1000, "end": 1200, "curve": -curves.CURVE_04},
	{"start": 1200, "end": 1400, "curve": curves.CURVE_05},
	{"start": 1400, "end": 1600, "curve": curves.CURVE_02},
	{"start": 1600, "end": 1800, "curve": curves.CURVE_04},
	{"start": 1800, "end": 2000, "curve": -curves.CURVE_02},
	{"start": 2000, "end": 2200, "curve": -curves.CURVE_04},
	{"start": 2200, "end": 2400, "curve": curves.CURVE_04},
	{"start": 2400, "end": 2600, "curve": curves.CURVE_05},
	{"start": 2600, "end": 2800, "curve": -curves.CURVE_04},
	{"start": 2800, "end": 3000, "curve": -curves.CURVE_05},
]

func generate_curve_conditions():
	for i in range(15):
		curve_conditions.append({"start": 150 + (i * 100), "end": 250 + (i * 100), "curve": generate_curve()})
		i += 1


var blocks = 0
func controller_runway(index):	
	if blocks >= road_block_pool.size():
		blocks = 0		
	var instance_road_block = road_block_pool[blocks]
	blocks += 1	
	if (index > 200 && index % 140 == 0):
		lines[index].set_name_sprite(5)
		lines[index].set_sprite(instance_road_block)
		lines[index].set_sprite_x(rand_range(-3, 3))
	
	# Curve on right
	for condition in curve_conditions:
		if index > condition["start"] && index < condition["end"]:
			lines[index].set_curve(condition["curve"])
	
	# Additional condition for the last case

	
func _on_car_collision():
	current_position -= 2000
	speed = 0
