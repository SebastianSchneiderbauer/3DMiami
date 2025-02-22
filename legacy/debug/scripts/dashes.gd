extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	text = "\n\n\n\n\n\n\n\n\n\n\n\n\ndashes: " + str(player.dashes + (player.dashRegenTimer/player.dashRegenTime)).substr(0,str(player.dashes).length() + 2) + " (of: " + str(player.maxDashes) + ")"
#maxDashes,dashes,dashRegenTimer,dashRegenTime
