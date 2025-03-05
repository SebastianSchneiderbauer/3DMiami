extends Node

const SAVE_PATH := "user://save_data.txt"
const DEFAULT_SAVE_PATH := "res://autoloader/default_save.txt"
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
			var line = file.get_line().strip_edges()

			# Ignore comments and empty lines
			if line.is_empty() or line.begins_with("#"):
				continue

			var parts = line.split("=")
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				# Auto-detect numbers
				if value.is_valid_int():
					save_data[key] = value.to_int()
				elif value.is_valid_float():
					save_data[key] = value.to_float()
				# Detect Vector3 and Number Arrays Separately
				elif "," in value:
					var elements = value.split(",")
					# Check if all parts are numbers
					var all_numbers = true
					for element in elements:
						if not element.is_valid_float():
							all_numbers = false
							break
					if all_numbers:
						if elements.size() == 3:  # Vector3 case
							save_data[key] = Vector3(elements[0].to_float(), elements[1].to_float(), elements[2].to_float())
						else:  # Number array case
							save_data[key] = Array(elements).map(func(e): return e.to_float())  # Fix applied here
					else:
						save_data[key] = elements  # Regular string array
				else:
					save_data[key] = value
	else:
		print("No save file found. Loading defaults from default_save.txt.")
		load_default_save_data()
		save_game()

func set_data(property_name: String, value):
	save_data[property_name] = value
	save_game()

func get_data(property_name: String):
	return save_data.get(property_name, null)

func get_all_data():
	return save_data  # Returns the entire save data dictionary for debugging

func load_default_save_data():
	if FileAccess.file_exists(DEFAULT_SAVE_PATH):
		var file = FileAccess.open(DEFAULT_SAVE_PATH, FileAccess.READ)
		save_data.clear()
		while not file.eof_reached():
			var line = file.get_line().strip_edges()

			# Ignore comments and empty lines in default save file
			if line.is_empty() or line.begins_with("#"):
				continue

			var parts = line.split("=")
			if parts.size() == 2:
				save_data[parts[0].strip_edges()] = parts[1].strip_edges()
	else:
		print("Warning: Default save file not found at ", DEFAULT_SAVE_PATH)
