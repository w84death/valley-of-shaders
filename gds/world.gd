extends Spatial

export var GAME_MODE = 1
onready var templates = [
	preload('res://tscns/knight.tscn')
]
onready var maps = [
	preload("res://pngs/map1.png"),
	preload("res://pngs/map2_heightmap.png")
]

var counter = 1

func _ready():
	pass

func edit_heightmap(pos):
	var data = maps[0].get_data()
	data.lock()
	var c = data.get_pixel(pos.x, pos.y)
	data.set_pixel(pos.x, pos.y, Color(c.r * 0.9))
	data.unlock()
	
func spawn_knight(pos):
	var temp = templates[0].instance()
	temp.translate(pos)
	$spam.add_child(temp)
	counter += 1
	refresh_knights_counter()
	
func refresh_knights_counter():
	$HUD/counter.set_text('Knights on map: ' + str(counter))

func change_map_to(id):
	for i in 128:
		spawn_knight(Vector3(-256 + randf()*512, 64.0, -128 + randf() * 256))
	#$terrain.get_surface_material(0).set_shader_param("heightmap", maps[0])