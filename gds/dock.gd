extends Position3D

var ships_path = 'user://ships/'
var ships = []

func _ready():
	pass
	dir_contents(ships_path, ships)
	print(ships)
	if ships.size() > 0:
		var temp = ships[ships.size()-1].instance()
		add_child(temp)
	
func dir_contents(path, array):
	var dir = Directory.new()
	var regex = RegEx.new()
	regex.compile("[^\\s]+(\\.(?i)(dae))$")
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if not dir.current_is_dir():
				print("Found file:" + file_name)
				var dae_file = regex.search(file_name)
				if dae_file:
					array.append(load('mods/ships/' + dae_file.get_string()))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the /ships/ directory.")
		if not dir.dir_exists(ships_path):
			dir.make_dir(ships_path)
			print("Created empty /ships/ dir.")
		