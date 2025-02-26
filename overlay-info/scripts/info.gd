extends Control

@onready var fps_label:Label = $fps

func _physics_process(delta):
	fps_label.text = "fps: " + str(1/delta)
