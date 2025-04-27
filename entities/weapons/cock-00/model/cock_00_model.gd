extends CharacterBody3D

@export var firing: bool = false
var gravity := Vector3(0,-9.81,0)

func _physics_process(delta: float) -> void:
	if firing:
		$MeshInstance3D2.set_layer_mask_value(1,true) 
		$MeshInstance3D2.set_layer_mask_value(19,false) 
		$MeshInstance3D3.set_layer_mask_value(1,true) 
		$MeshInstance3D3.set_layer_mask_value(19,false) 
		
		if is_on_ceiling() or is_on_wall():
			velocity.x = 0
			velocity.z = 0
			
			if velocity.y > 0:
				velocity.y = 0
		elif is_on_floor():
			firing = false
		else:
			velocity += gravity*delta
			if velocity.y < -9.81:
				pass#velocity.y = -9.810
		
		move_and_slide()
