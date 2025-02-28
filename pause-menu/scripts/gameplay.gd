extends Control

func _on_return_pressed():
	var ani:AnimationPlayer = get_node("../AnimationPlayer")
	ani.play("base-show")

func _process(delta):
	var sens_slider:HSlider = $Options/ScaleBox/ScaleSlider
	var sens_label:Label = $Options/ScaleBox/ScaleLabel
	var fov_slider:HSlider = $Options/ScaleBox2/FOVSlider
	var fov_label:Label = $Options/ScaleBox2/FOVLabel
	var player:CharacterBody3D = get_node("../../../player")
	var cam:Camera3D = player.get_node("camera")
	
	#sensi
	sens_label.set_text(str(sens_slider.value))
	player.sensitivity = sens_slider.value
	
	#fov
	fov_label.set_text(str(fov_slider.value))
	cam.set_fov(fov_slider.value)
