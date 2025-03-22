extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://world-00/scenes/world.tscn")
	Discord.change("details","Test Map 00")
	Discord.update()
