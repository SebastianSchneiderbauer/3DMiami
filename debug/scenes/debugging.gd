extends Label

var timer:float = -1
var showtime:float = 0.3
var currentlyShown:String = ""

func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	
	var extra = ""
	if Input.is_action_just_pressed("debug1"):
		extra = "1"
	elif Input.is_action_just_pressed("debug2"):
		extra = "2"
	elif Input.is_action_just_pressed("debug3"):
		extra = "3"
	elif Input.is_action_just_pressed("debug4"):
		extra = "4"
	
	if extra != "" and player.isDebugging:
		currentlyShown = " (" + extra + ")"
		timer = 0
	
	if timer != -1:
		timer += delta
	
	if timer > showtime:
		timer = -1
		currentlyShown = ""
	
	text = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ndebugging: " + str(player.isDebugging) + currentlyShown
