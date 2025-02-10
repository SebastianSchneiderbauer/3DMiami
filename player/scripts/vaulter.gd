extends CharacterBody3D

func _physics_process(delta):
	velocity = Vector3(0,-130,0)
	move_and_slide()
