extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "FPS: " + str(round(1/delta))
