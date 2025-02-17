extends CharacterBody3D

func can_vault() -> bool:
	var vaultChecker:RayCast3D = $vaultChecker
	var posi:Vector3 = get_parent().global_position
	
	posi.y += 3
	
	var transVector:Vector3 = posi - vaultChecker.global_position #used to translate the global position vector into the scene coordinate system
	
	vaultChecker.target_position = vaultChecker.position - transVector #translate the global coords in to scene coordinates
	vaultChecker.force_raycast_update()
	
	return not vaultChecker.is_colliding()

func _physics_process(delta):
	velocity = Vector3(0,-130,0)
	move_and_slide()
