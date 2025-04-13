extends Node

const SAVE_PATH := "user://save_data.txt"
var save_data := {}

signal save_data_update
var loaded:bool = false

# Default values (Embedded for portability)
var default_values := {
	"sensitivity": 0.2,
	"fov": 100,
	"showCrosshair": true,
	"crosshairScale": 0.01,
	"scaler": 2,
	"fsrStrength": 1,
	"scalerStrength": 100.0,
	"fullScreen": false,
	"VSYNC": true,
	"capFPS": true,
	"FPScap": 100,
	"defaultScreen": 0,
	"highlightColor": Color(1,0,0,1)
}

func _ready():
	load_game()
	loaded = true

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	for key in save_data.keys():
		file.store_line(key + "=" + str(save_data[key]))
	
	emit_signal("save_data_update")

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
		print("No save file found. Loading defaults.")
		reset_to_defaults()  # Use embedded defaults
		save_game()

func reset_to_defaults():
	save_data = default_values.duplicate()  # Copy fresh default values
	save_game()

func reset_property_to_default(property_name: String):
	if default_values.has(property_name):
		save_data[property_name] = default_values[property_name]
		save_game()

func set_data(property_name: String, value):
	save_data[property_name] = value
	save_game()

func get_data(property_name: String):
	var result = save_data.get(property_name, null)
	if result == null:
		return 0
		print("!! NULL VALUE !!")
	else:
		return result

func get_default_value(property_name: String):
	""" Returns the default value for a given property from default_values. """
	return default_values.get(property_name, null)

func get_all_data():
	return save_data  # Returns the entire save data dictionary for debugging

# Helper function to ensure type detection is consistent
func parse_value(value: String):
	if value.to_lower() == "true":
		return true
	elif value.to_lower() == "false":
		return false
	elif value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
	elif "," in value:
		var elements = value.split(",")
		
		for i in elements.size():
			print(elements[i])
			elements[i] = elements[i].strip_edges().replace("(", "").replace(")", "")
		
		var all_numbers = true
		for element in elements:
			if not element.is_valid_float():
				all_numbers = false
				break
		
		if all_numbers:
			match elements.size():
				3:
					return Vector3(elements[0].to_float(), elements[1].to_float(), elements[2].to_float())
				4:
					return Color(elements[0].to_float(), elements[1].to_float(), elements[2].to_float(), elements[3].to_float())
				_:
					return Array(elements).map(func(e): return e.to_float())
		else:
			return elements
	else:
		return value
