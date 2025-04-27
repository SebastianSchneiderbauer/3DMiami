extends Node3D

var velocity := Vector3.ZERO
var firing: bool = false
var dropping: bool = false #have we hit anything and are just dropping now

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var floorchecker: RayCast3D = $floorchecker

func _physics_process(delta: float) -> void:
	if firing:
		print(velocity)
		
		$MeshInstance3D2.set_layer_mask_value(1,true) 
		$MeshInstance3D2.set_layer_mask_value(19,false) 
		$MeshInstance3D3.set_layer_mask_value(1,true) 
		$MeshInstance3D3.set_layer_mask_value(19,false) 
		
		ray_cast_3d.target_position = global_position + velocity*delta
		ray_cast_3d.force_raycast_update()
		
		if ray_cast_3d.is_colliding():
			if dropping:
				firing = false
			
			velocity.x = 0
			velocity.z = 0
			
			if velocity.y > 0:
				velocity.y = 0
			
			dropping = true
			
			global_position += velocity * delta
		else:
			global_position += velocity * delta
			velocity += Vector3(0, -9.81, 0) * delta
			if velocity.y < -9.81:
				velocity.y = -9.81
