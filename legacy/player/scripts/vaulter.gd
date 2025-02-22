extends CharacterBody3D

func can_vault() -> bool: #just checks if the vault is obstructed
	var vaultChecker:RayCast3D = $vaultChecker
	var posi:Vector3 = get_parent().global_position
	
	var transVector:Vector3 = posi - vaultChecker.global_position #used to translate the global position vector into the scene coordinate system
	
	vaultChecker.target_position = vaultChecker.position - transVector #translate the global coords in to scene coordinates
	vaultChecker.force_raycast_update()
	
	return not vaultChecker.is_colliding()
