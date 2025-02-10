extends CharacterBody3D

var diff = 0;

func _physics_process(delta):
	if Input.is_action_just_pressed("debug4"):
		velocity = Vector3(0,-100,0)
		
		move_and_slide()
		
		if is_on_floor():
			print("floor be like: ___________")
