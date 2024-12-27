extends Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player: CharacterBody3D = get_parent().get_parent().get_parent().get_child(0)
	text = "\n\nvelocity: (" + str(player.velocity.x).substr(0,4) + ", " + str(player.velocity.y).substr(0,4) + ", " + str(player.velocity.z).substr(0,4) + ")"
