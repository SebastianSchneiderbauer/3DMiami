extends Control

func _on_return_pressed():
	var ani:AnimationPlayer = get_node("../AnimationPlayer")
	ani.play("base-show")

func _process(delta):
	var sens_slider:HSlider = $Options/ScaleBox/ScaleSlider
	var sens_label:Label = $Options/ScaleBox/ScaleLabel
	var fov_slider:HSlider = $Options/ScaleBox2/FOVSlider
	var fov_label:Label = $Options/ScaleBox2/FOVLabel
	var crosshair_slider:HSlider = $Options/ScaleBox3/crosshairSlider
	var crosshair_label:Label = $Options/ScaleBox3/crosshairLabel
	var player:CharacterBody3D = get_node("../../../player")
	var cam:Camera3D = player.get_node("camera")
	var crosshair:TextureRect = get_node("../../crosshair/TextureRect")
	
	#sensi
	sens_label.set_text(str(sens_slider.value))
	player.sensitivity = sens_slider.value
	
	#fov
	fov_label.set_text(str(fov_slider.value))
	cam.set_fov(fov_slider.value)
	
	#crosshair
	crosshair.scale = Vector2(crosshair_slider.value,crosshair_slider.value)
	crosshair_label.set_text(str(crosshair_slider.value))
