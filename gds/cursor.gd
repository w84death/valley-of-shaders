extends Spatial

export var GAME_MODE = 1

export var MAP_SIZE = Vector2(1024, 512)
export var MAP_HEIGHT_FACTOR = 64
export var BLUE_LINE = 0.2
export var GREEN_LINE = 0.45
export var MOVE_FACTOR = 2.0

var move_to
var height_map
onready var heightmap_data = load("res://pngs/map1.png")

func _ready():
	height_map = heightmap_data.get_data()
	transform.origin.y = get_adjusted_height(get_pos())
	move_to = transform.origin

func get_pos():
	return Vector2(int(MAP_SIZE.x*.5+transform.origin.x), int(MAP_SIZE.y*.5+transform.origin.z))
	
func _process(delta):
	if move_to != transform.origin:
		move_to.y = get_adjusted_height(get_pos())
		
		if move_to.y < BLUE_LINE:
			move_to.y = BLUE_LINE
			
		transform.origin += (move_to - transform.origin) * delta * MOVE_FACTOR

func get_adjusted_height(pos):
	var ah = get_height(pos).r * MAP_HEIGHT_FACTOR
	#print(pos, ah)
	return ah
	
func get_height(pos):
	var px = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < MAP_SIZE.x && pos.y < MAP_SIZE.y:
		height_map.lock()
		px = height_map.get_pixel(pos.x, pos.y)
		height_map.unlock()
	return px
	
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if Input.is_key_pressed(KEY_C):
		cinematic_mode()

	if GAME_MODE > 0:
		if Input.is_action_pressed("game_up"):
			move_forward()
		if Input.is_action_pressed("game_down"):
			move_backward()
		if Input.is_action_pressed("game_left"):
			move_left()
		if Input.is_action_pressed("game_right"):
			move_right()

		if Input.is_action_pressed("game_x"):
			select_x()
		
		if Input.is_action_pressed("game_a"):
			select_a()

func move_forward(): move_to.z -= 4
func move_backward(): move_to.z += 4
func move_left(): move_to.x -= 4
func move_right(): move_to.x += 4


func cinematic_mode(): return
func select_a():
	$"..".spawn_knight(transform.origin)
	$"..".spawn_knight(transform.origin)
	$"..".spawn_knight(transform.origin)
	$"..".spawn_knight(transform.origin)
	$"..".spawn_knight(transform.origin)
	
func select_x():
	$"..".change_map_to(1)