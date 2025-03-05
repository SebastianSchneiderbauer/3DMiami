extends Control

func _on_return_pressed():
	var ani:AnimationPlayer = get_node("../AnimationPlayer")
	ani.play("base-show")
