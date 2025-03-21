extends Area3D

@export var reset_position:Vector3 = Vector3(0,0,0)
@export var damage:int = 0
@export var stop_at_1:bool = true

func _on_body_entered(body):
	body.global_position = reset_position
	
