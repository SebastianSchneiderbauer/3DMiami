extends MeshInstance3D

@onready var particles: GPUParticles3D = $particles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SaveManager.save_data_update.connect(_on_savedata_update)
	material_overlay.set_shader_parameter("outline_color", SaveManager.get_data("highlightColor"))
	$"particles".get_draw_pass_mesh(0).get_material().albedo_color = SaveManager.get_data("highlightColor")
	$"OmniLight3D".light_color = SaveManager.get_data("highlightColor")

func _on_savedata_update():
	material_overlay.set_shader_parameter("outline_color", SaveManager.get_data("highlightColor"))
	$"particles".get_draw_pass_mesh(0).get_material().albedo_color = SaveManager.get_data("highlightColor")
	$"OmniLight3D".light_color = SaveManager.get_data("highlightColor")

func start():
	if not visible:
		show()
		particles.restart()
		animation_player.play("show")

func end():
	hide()
	
	particles.emitting = false
