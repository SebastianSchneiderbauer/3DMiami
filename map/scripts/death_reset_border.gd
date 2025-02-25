extends Area3D

@export var reset_position:Vector3 = Vector3(0,0,0)

func _on_body_entered(body):
	body.position = reset_position
