extends Position3D

export var MAP_SIZE = Vector2(1024, 1024)
export var MOVE_FACTOR = 8.0
export var AI_THINKING_LAG_FACTOR = 0.1

var rotate_speed = 4
var angle = 0
var _angle = 0

var move_to

func _ready():
	randomize()
	move_to = transform.origin
	ai_make_move()

func _process(delta):
	if angle != _angle:
		_angle += (angle - _angle) * delta * rotate_speed;

	var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle))
	transform.basis = basis
	move_to.y = get_parent().get_parent().get_height(transform.origin)
	if move_to != transform.origin:
		transform.origin += (move_to - transform.origin) * delta * MOVE_FACTOR
			
func _on_Timer_timeout():
	ai_make_move()

func ai_make_move():
	var AI_MOVE_RANGE = 4
	if randf() > 0.75:
		angle += -45 + randf() * 90
		
	if randf() > 0.5:
		move_to.x += -AI_MOVE_RANGE + randf() * (AI_MOVE_RANGE*2)
		move_to.z += -AI_MOVE_RANGE + randf() * (AI_MOVE_RANGE*2)
	$ai_tick.set_wait_time(randf()*AI_THINKING_LAG_FACTOR)