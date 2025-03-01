extends Control

@onready var fps_label:Label = $fps

func _process(delta):
	fps_label.text = "fps: " + str(1/delta)
	fps_label.text += "\nonwall: " + str(get_node("../../player").is_on_wall())
	fps_label.text += "\nonfloor: " +str(get_node("../../player").is_on_wall())
