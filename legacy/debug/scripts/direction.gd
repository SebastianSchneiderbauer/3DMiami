extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	text = "\n\n\ndirection: (" + str(player.direction.x).substr(0,4) + ", " + str(player.direction.y).substr(0,4) + ", " + str(player.direction.z).substr(0,4) + ")"
