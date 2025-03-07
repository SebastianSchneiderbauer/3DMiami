extends Node

const SAVE_PATH := "user://save_data.txt"
const DEFAULT_SAVE_PATH := "res://autoloader/default_save.txt"
var save_data := {}

signal save_data_update
var loaded:bool = false

func _ready():
	load_game()
	loaded = true

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
				save_data[key] = parse_value(value)  # Use the same type detection
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
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				save_data[key] = parse_value(value)  # Ensure correct types

		emit_signal("save_data_update")
	else:
		print("Warning: Default save file not found at ", DEFAULT_SAVE_PATH)

# Helper function to ensure type detection is consistent
func parse_value(value: String):
	# Auto-detect boolean
	if value.to_lower() == "true":
		return true
	elif value.to_lower() == "false":
		return false
	# Auto-detect numbers
	elif value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
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
				return Vector3(elements[0].to_float(), elements[1].to_float(), elements[2].to_float())
			else:  # Number array case
				return Array(elements).map(func(e): return e.to_float())
		else:
			return elements  # Regular string array
	else:
		return value  # Default to string
