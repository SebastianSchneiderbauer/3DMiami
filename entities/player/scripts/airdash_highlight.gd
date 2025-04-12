extends MeshInstance3D

@onready var particles: GPUParticles3D = $particles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func start():
	if not visible:
		show()
		particles.restart()
		animation_player.play("show")

func end():
	hide()
	
	particles.emitting = false
