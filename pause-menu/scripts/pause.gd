extends Control

var paused:bool = false
@onready var animationPlayer:AnimationPlayer = $AnimationPlayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		paused = not paused
		
		get_tree().paused = paused
		if(paused):
			animationPlayer.play("base-show")
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			animationPlayer.play("base-hide")
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed():
	paused = false
	get_tree().paused = paused
	animationPlayer.play("base-hide")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_gameplay_pressed():
	animationPlayer.play("gameplay-show")


func _on_graphics_pressed():
	animationPlayer.play("graphic-show")
