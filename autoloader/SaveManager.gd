extends Node

const SAVE_PATH := "user://save_data.txt"
var save_data := {}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	for key in save_data.keys():
		file.store_line(key + "=" + str(save_data[key]))

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		save_data.clear()
		while not file.eof_reached():
			var line = file.get_line()
			var parts = line.split("=")
			if parts.size() == 2:
				save_data[parts[0]] = parts[1]
	else:
		print("No save file found. Creating a new one.")
		set_default_save_data()
		save_game()

func set_data(property_name: String, value):
	save_data[property_name] = value
	save_game()

func get_data(property_name: String):
	return save_data.get(property_name, null)

func set_default_save_data():
	save_data = {
		"health": 100,
		"player_position": "0,0,0",
		"inventory": ""
	}
