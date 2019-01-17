extends Position3D

export var MAP_SIZE = Vector2(1024, 512)
export var MAP_HEIGHT_FACTOR = 64
export var BLUE_LINE = 0.2
export var GREEN_LINE = 0.45

onready var units = [
	preload('res://tscns/knight.tscn')
]

func _ready():
	pass

func spawn_knight():
	var new_unit = units[0].instance()
	$units.add_child(new_unit)

func _on_tower_tick_timeout():
	spawn_knight()
