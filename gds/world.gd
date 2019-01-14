extends Spatial

export var GAME_MODE = 1
onready var templates = [
	preload('res://tscns/knight.tscn')
]
onready var maps = [
	preload("res://pngs/heightmap_castle.png"),
	preload("res://pngs/map2_heightmap.png")
]

var counter = 1

func _ready():
	refresh_knights_counter()


func spawn_knight(pos):
	var temp = templates[0].instance()
	temp.translate(pos)
	$spam.add_child(temp)
	counter += 1
	refresh_knights_counter()
	
func refresh_knights_counter():
	$HUD/counter.set_text('Knights on map: ' + str(counter))

func change_map_to(id):
	if $terrain.is_visible_in_tree():
		$terrain.hide()
		$terrain2.show()
	else:
		$terrain.show()
		$terrain2.hide()