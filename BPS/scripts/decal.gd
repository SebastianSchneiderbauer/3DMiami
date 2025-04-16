extends MeshInstance3D

var counter: float = 1.0
var fade_duration: float = 1.0
var fading: bool = false

@onready var mat := StandardMaterial3D.new()

func _ready() -> void:
	var path = "res://BPS/textures/splats/glob1.png"
	
	var image := Image.new()
	if image.load(path) != OK:
		push_error("Failed to load image: " + path)
		return
	
	var tex := ImageTexture.create_from_image(image)
	
	mat.albedo_texture = tex
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = 0
	mat.flags_transparent = true
	mat.alpha_scissor_threshold = 0.1
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.albedo_color = Color(1, 1, 1, 1) # full opacity
	
	set_surface_override_material(0, mat)

func _process(delta: float) -> void:
	if not fading:
		counter -= delta
		if counter <= 0:
			counter = 0
			fading = true
	else:
		counter += delta
		var alpha = clamp(1.0 - (counter / fade_duration), 0.0, 1.0)
		mat.albedo_color.a = alpha
		
		if counter >= fade_duration:
			queue_free()
