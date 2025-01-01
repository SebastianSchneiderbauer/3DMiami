extends Control

# Tracks the pause state
var is_paused: bool = false

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):  # "ui_cancel" is bound to Escape by default
		toggle_pause()

func toggle_pause():
	if freeCamToggle:
		freeCamToggle = false
	
	is_paused = !is_paused
	if is_paused:
		# Pause the game
		get_tree().paused = true
		$AnimationPlayer.play("fade_in")
		get_child(2).show()
		# Show and release the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		# Unpause the game
		get_tree().paused = false
		$AnimationPlayer.play("fade_out")
		# Lock the mouse back to the center
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var freeCamToggle = null
var timer = 0

func _process(delta: float) -> void:
	if get_child(1).is_pressed():
		get_parent().get_child(1).visible = not freeCamToggle
	
	if Input.is_action_just_pressed("F") and get_child(1).is_pressed():
		if is_paused and visible:
			return
			
		toggle_pause()
		freeCamToggle = is_paused
	
	if freeCamToggle == true:
		timer = 0
		visible = false
		get_parent().get_parent().get_child(5).toggle = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif freeCamToggle == false:
		visible = false
		get_parent().get_parent().get_child(5).toggle = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		freeCamToggle = null
	else:
		timer += delta
		if timer > 0.5:
			visible = true


func _on_graphics_pressed() -> void:
	$VBoxContainer.hide()
	$"graphics setting".show()
	get_child(2).hide()
