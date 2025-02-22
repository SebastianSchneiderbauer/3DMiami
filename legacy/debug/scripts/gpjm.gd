extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	text = "\n\n\n\n\n\n\n\n\n\nGPJM: " + str(player.groundPoundJumpMultiplier).substr(0,(str(round(player.groundPoundJumpMultiplier)).length()+4))
