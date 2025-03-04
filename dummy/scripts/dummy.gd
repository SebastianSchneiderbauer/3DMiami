extends CharacterBody3D


func _on_player_push_area_body_entered(body: Node3D) -> void:
	print("collision detected") #would have to trigger a push
