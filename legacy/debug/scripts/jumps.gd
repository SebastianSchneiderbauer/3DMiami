extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	text = "\n\n\n\n\n\n\n\njumps: " + str(player.jumps) + " (of: " + str(player.maxJumps) + ")"
