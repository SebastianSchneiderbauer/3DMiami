extends HSlider

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var output = get_parent().get_child(2)
	var player = get_parent().get_parent().get_parent().get_parent().get_parent().get_child(0)
	var camera = player.get_child(1)
	output.set_text(str(value)) #IMPORTANT
	player.sensitivity = value
