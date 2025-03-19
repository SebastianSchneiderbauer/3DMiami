extends TBLoader

func _ready():
	for child in get_children():
		if child is OmniLight3D:
			child.shadow_enabled = true
