extends Node

@export var reset := Vector3(0,0,0) 

func _on_body_entered(body: Node3D) -> void:
	body.global_position = reset
