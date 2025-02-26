extends Control

var paused:bool = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		paused = not paused
