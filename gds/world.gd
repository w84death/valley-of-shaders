extends Spatial

export var MAP_SIZE = Vector2(1024, 512)
export var MAP_HEIGHT_FACTOR = 64
export var GAME_MODE = 1
export var BLUE_LINE = 0.2
export var GREEN_LINE = 0.45

onready var heightmap_file = preload("res://mats/heightmap.tres")
onready var structures = [
	preload('res://tscns/tower.tscn')
]
var height_map

func _ready():
	height_map = heightmap_file.get_noise()

func change_map_to(id):
	pass

func read_pixel(pos):
	var pos2 = convert_pos(pos)
	var h = height_map.get_noise_2d(pos2.x, pos2.y)
	#if pos2.x >= 0 && pos2.y >= 0 && pos2.x < MAP_SIZE.x && pos2.y < MAP_SIZE.y:
	#h = height_map.get_noise_2d(pos2.x, pos2.y)
	if h < BLUE_LINE: h = BLUE_LINE
	return h
	
func get_height(pos):
	var h = read_pixel(pos) * MAP_HEIGHT_FACTOR
	return h
	
func convert_pos(pos):
	return Vector2(int(MAP_SIZE.x*.5+pos.x), int(MAP_SIZE.y*.5+pos.z))
	
func spawn_tower(pos):
	var new_str = structures[0].instance()
	new_str.translate(Vector3(pos.x, get_height(pos) , pos.z))
	$towers.add_child(new_str)

func refresh_y_positions():
	var counter = 0
	for tower in $towers.get_children():
		for unit in tower.get_node('units').get_children():
			unit.move_to.y = get_height(unit.transform.origin)
			counter += 1
	refresh_units_counter(counter)

func refresh_units_counter(counter):
	$HUD/counter.set_text('Units on map: ' + str(counter))

func _on_world_tick_timeout():
	refresh_y_positions()
