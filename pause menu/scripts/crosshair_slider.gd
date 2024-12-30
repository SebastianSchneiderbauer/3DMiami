extends HSlider

func _process(delta):
	var output = get_parent().get_child(9)
	var crosshair = get_parent().get_parent().get_parent().get_child(2).get_child(0)
	
	output.set_text(str(value))
	crosshair.multiplier = value
