extends CharacterBody3D

func can_vault() -> bool:
	var vaultChecker:RayCast3D = $vaultChecker
	vaultChecker.target_position = get_parent().position
	vaultChecker.force_raycast_update()
	
	return not vaultChecker.is_colliding()

func _physics_process(delta):
	velocity = Vector3(0,-130,0)
	move_and_slide()
