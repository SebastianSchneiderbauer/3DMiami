extends Control

@onready var fps_label:Label = $fps
@onready var player:CharacterBody3D = get_node("../../player")

func _process(delta):
	fps_label.text = "fps: " + str(1/delta)
	fps_label.text += "\nonwall: " + str(player.is_on_wall())
	fps_label.text += "\nonfloor: " +str(player.is_on_wall())
	fps_label.text += "\nglobalPosition: " + str(player.global_position)
	fps_label.text += "\ndirection: " + str(player.direction)
