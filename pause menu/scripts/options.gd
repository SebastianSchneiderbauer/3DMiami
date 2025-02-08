extends VBoxContainer

func _on_return_pressed() -> void:
	get_parent().hide()
	get_parent().get_parent().get_child(0).show()
	get_parent().get_parent().get_child(2).show()
