extends Position3D


export var MAP_SIZE = Vector2(256, 256)
export var BLUE_LINE = 0.16
export var GREEN_LINE = 0.44
export var MOVE_FACTOR = 2.0
export var MAP_HEIGHT_FACTOR = 64
export var AI_THINKING_LAG_FACTOR = 0.5
var anim = 'idle'

var move_to
var height_map
onready var heightmap_data = load("res://pngs/heightmap_castle.png")

func _ready():
	randomize()
	height_map = heightmap_data.get_data()
	transform.origin.y = get_adjusted_height(get_pos())
	move_to = transform.origin
	ai_make_move()

func get_pos():
	return Vector2(int(MAP_SIZE.x*.5+transform.origin.x), int(MAP_SIZE.y*.5+transform.origin.z))
	
func _process(delta):
	if move_to != transform.origin:
		move_to.y = get_adjusted_height(get_pos())
		
		if move_to.y < BLUE_LINE:
			move_to.y = BLUE_LINE
			
		transform.origin += (move_to - transform.origin) * delta * MOVE_FACTOR
		
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	look_at(camera_pos, Vector3(0, 1, 0))
	
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

func _on_Timer_timeout():
	ai_make_move()

func ai_make_move():
	var AI_MOVE_RANGE = 4
	
	if randf() > 0.5:
		move_to.x += -AI_MOVE_RANGE + randf() * (AI_MOVE_RANGE*2)
		move_to.z += -AI_MOVE_RANGE + randf() * (AI_MOVE_RANGE*2)
		$body.play("run")
	else:
		$body.play("idle")
	$ai_tick.set_wait_time(randf()*AI_THINKING_LAG_FACTOR)