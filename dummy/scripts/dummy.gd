extends CharacterBody3D

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

var pushVelocity

func movement(delta:float):
	#increase gravity while falling
	if velocity.y < 0 and not is_on_wall():
		used_gravity.y -= gravity_changer*delta
	else:
		used_gravity = default_gravity
	
	if not is_on_floor():
		velocity += used_gravity * delta
	
	move_and_slide()

func _physics_process(delta: float) -> void:
	movement(delta)

func _on_player_push_area_body_entered(body: Node3D) -> void:
	print("collision detected") #would have to trigger a push
