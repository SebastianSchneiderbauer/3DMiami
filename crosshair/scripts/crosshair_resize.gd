extends TextureRect

var multiplier:float = 1

func _process(delta: float) -> void:
	size = Vector2(texture.get_width(), texture.get_height()) * multiplier
	
	# Center the TextureRect on the screen
	position = (get_viewport_rect().size / 2) - (size / 2)
