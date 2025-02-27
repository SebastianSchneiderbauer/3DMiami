extends Control

@onready var fps_label:Label = $fps

func _process(delta):
	fps_label.text = "fps: " + str(1/delta)
	print(delta)
	print(1/delta)
