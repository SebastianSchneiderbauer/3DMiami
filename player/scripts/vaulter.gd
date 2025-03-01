extends CharacterBody3D

@onready var player:CharacterBody3D = $"../"
@onready var wallchecker:RayCast3D = $wallchecker #checking for walls in the way, fixes vaulting threw ceilings
@export var height:float

func can_vault() -> bool:
	wallchecker.global_position = global_position
	wallchecker.global_position.y += 1
	wallchecker.target_position = player.global_position
	wallchecker.target_position.y += 1
	wallchecker.force_raycast_update()
	return not wallchecker.is_colliding() and (global_position.y-1) - player.global_position.y > 0.001

func _physics_process(delta):
	global_position = player.global_position + player.direction*1
	global_position.y += 1+height
	
	velocity = Vector3(0,-100,0)
	move_and_slide() #moving to aproximatly the ground
	velocity = Vector3(0,-9.81,0)
	move_and_slide() #moving to exactly the ground
