extends MeshInstance3D

const GLOBS = [
	"res://BPS/textures/splats/glob1.png",
	"res://BPS/textures/splats/glob2.png",
	"res://BPS/textures/splats/glob3.png",
	"res://BPS/textures/splats/glob4.png"
]

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var path = GLOBS[rng.randi_range(0, GLOBS.size() - 1)]

	var image := Image.new()
	if image.load(path) != OK:
		push_error("Failed to load image: " + path)
		return

	var tex := ImageTexture.create_from_image(image)

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex

	# Shaded + Transparent
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.texture_filter = 0
	mat.flags_transparent = true
	mat.alpha_scissor_threshold = 0.1
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL # enables lighting

	set_surface_override_material(0, mat)
