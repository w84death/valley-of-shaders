extends Position3D

export var rotate_speed = 1.0;
export var move_speed = 1.0;
export var move_speed_lr = 0.5;
export var move_speed_fb = 1.5;

var active_camera = 0
onready var cameras = [
	$"camera_drone",
	$"camera_satelite",
	$"boat/camera_onboard"
]
const DEADZONE = 0.15;

var angle_x = 0;
var angle_y = 250;

var _angle_x = 0;
var _angle_y = 250;

var move_to;
var w = 0
var axis_value;

func _ready():
	move_to = transform.origin

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0;
		_angle_y += (angle_y - _angle_y) * delta * 10.0;

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis
		
	if move_to != transform.origin:
		move_to.y = get_parent().get_height(transform.origin)
		transform.origin += (move_to - transform.origin) * delta * 10.0
		
func _input(event):
	if Input.is_action_pressed("game_left"):
		angle_y += rotate_speed
	if Input.is_action_pressed("game_right"):
		angle_y -= rotate_speed
	if Input.is_action_pressed("game_up"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to -= front_back * move_speed;
	if Input.is_action_pressed("game_down"):
		var front_back = transform.basis.z
		front_back.y = 0.0
		front_back = front_back.normalized()
		move_to += front_back * move_speed;
	if Input.is_key_pressed(KEY_ESCAPE):
		quit_game()
	if Input.is_action_pressed("game_a"):
		select_a()
	if Input.is_action_pressed("game_x"):
		select_x()
		
func _physics_process(delta):
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		axis_value = Input.get_joy_axis(0, axis)
		var axis_abs = abs(axis_value)
		if axis_abs > DEADZONE:
			# ROTATE LEFT - RIGHT
			if axis == JOY_ANALOG_RX:
				if axis_value > 0:
					angle_y -= rotate_speed * axis_abs
				else:
					angle_y += rotate_speed * axis_abs
					
			# ROTATE ..THE OTEHR WAY :P
			##
			#if axis == JOY_ANALOG_RY:
			#	if axis_value > 0:
			#		if angle_x > -25:
			#			angle_x -= rotate_speed * axis_abs
			#	else:
			#		if angle_x < 25:
			#			angle_x += rotate_speed * axis_abs

			# MOVE LEFT - RIGHT
			#if axis == JOY_ANALOG_LX:
			#	if axis_value < 0:
			#		var left_right = transform.basis.x
			#		left_right.y = 0.0
			#		left_right = left_right.normalized()
			#		move_to -= left_right * move_speed_lr * axis_abs;
			#	else:
			#		var left_right = transform.basis.x
			#		left_right.y = 0.0
			#		left_right = left_right.normalized()
			#		move_to += left_right * move_speed_lr * axis_abs;

			# MOVE FRONT - BACK
			if axis == JOY_ANALOG_LY:
				if axis_value < 0:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to -= front_back * move_speed_fb * abs(axis_value);
				else:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to += front_back * move_speed_fb * abs(axis_value);

		
func select_a():
	get_parent().change_map_seed()
	
func select_x():
	active_camera += 1
	if active_camera > 2:
		active_camera = 0
	
	cameras[active_camera].set_current(true)
	
func quit_game():
	get_tree().quit()