extends MeshInstance3D

var counter: float = 1.0
var fade_duration: float = 1.0
var fading: bool = false

func _process(delta: float) -> void:

	if not fading:
		counter -= delta
		if counter <= 0:
			counter = 0
			fading = true
	else:
		counter += delta
		var alpha = clamp(1.0 - (counter / fade_duration), 0.0, 1.0)
		mesh.get_material().albedo_color.a = alpha
		
		if counter >= fade_duration:
			queue_free()
