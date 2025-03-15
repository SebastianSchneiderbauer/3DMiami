extends Control

var start = -8
var end = -156.0
var diff = end - start
@onready var node_2d:Node2D = $Options/Node2D
@onready var v_slider:VSlider = $VSlider

func _process(delta):
	if Input.is_action_pressed("ui_cancel") and visible:
		hide()
	
	if visible:
		if Input.is_action_just_pressed("mouseWheelUp"):
			v_slider.value -= v_slider.step*1000*delta
		
		if Input.is_action_just_pressed("mouseWheelDown"):
			v_slider.value += v_slider.step*1000*delta
		
		node_2d.position.y = start + diff*v_slider.value
	else:
		v_slider.value = 0

func _on_return_pressed():
	var animationPlayer:AnimationPlayer = get_node("../AnimationPlayer")
	animationPlayer.play("base-show")
