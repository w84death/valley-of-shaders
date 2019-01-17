extends Spatial

export var GAME_MODE = 1
export var MOVE_FACTOR = 2.0

var move_to

func _ready():
	move_to = transform.origin

func _process(delta):
	if move_to != transform.origin:
		move_to.y = get_parent().get_height(transform.origin)
		transform.origin += (move_to - transform.origin) * delta * MOVE_FACTOR
	
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
	for i in 126:
		get_parent().spawn_unit(0, transform.origin)
	
func select_x():
	get_parent().change_map_seed()