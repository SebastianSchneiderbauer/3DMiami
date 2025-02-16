extends CharacterBody3D

func can_vault() -> bool:
	var vaultChecker:RayCast3D = $vaultChecker
	var posi:Vector3 = get_parent().position
	
	print(posi)
	posi.y += 1
	print("e")
	print(posi)
	
	vaultChecker.target_position = posi
	vaultChecker.force_raycast_update()
	
	return not vaultChecker.is_colliding()

func _physics_process(delta):
	velocity = Vector3(0,-130,0)
	move_and_slide()
