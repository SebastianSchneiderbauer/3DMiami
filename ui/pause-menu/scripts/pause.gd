extends Control

var paused:bool = false
var inSubMenu:bool = false
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if inSubMenu:
			inSubMenu = false
		else:
			paused = not paused
		
		get_tree().paused = paused
		
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if paused and not inSubMenu:
		get_node("VBoxContainer").show()
		get_node("ColorRect").show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_node("VBoxContainer").hide()
		get_node("ColorRect").hide()

func _on_resume_pressed():
	paused = false
	get_tree().paused = paused
	animationPlayer.play("base-hide")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_gameplay_pressed():
	animationPlayer.play("gameplay-show")
	inSubMenu = true

func _on_graphics_pressed():
	animationPlayer.play("graphic-show")
	inSubMenu = true

func _on_controlls_pressed():
	animationPlayer.play("controlls-show")
	inSubMenu = true
