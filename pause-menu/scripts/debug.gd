extends CheckButton

func _ready():
	toggle_visibility()

func _on_pressed():
	toggle_visibility()

func toggle_visibility():
	var info:Control = get_parent().get_parent().get_child(0)
	info.visible = is_pressed()
