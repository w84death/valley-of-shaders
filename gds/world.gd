extends Spatial

export var GAME_MODE = 1
onready var templates = [
	preload('res://tscns/knight.tscn')
]

func _ready():
	pass # Replace with function body.


func spawn_knight(pos):
	print(pos)
	var temp = templates[0].instance()
	temp.translate(pos)
	$spam.add_child(temp)