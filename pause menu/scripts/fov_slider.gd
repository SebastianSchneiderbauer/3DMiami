extends HSlider

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var output = get_parent().get_child(6)
	var player = get_parent().get_parent().get_parent().get_parent().get_child(0)
	var camera = player.get_child(1)
	var camera2 = player.get_child(2).get_child(0).get_child(0)
	output.set_text(str(value))
	camera.baseFOV = value
	#camera2.fov = value
