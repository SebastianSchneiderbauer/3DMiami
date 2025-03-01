extends CharacterBody3D

@onready var player:CharacterBody3D = $"../"

func _physics_process(delta):
	print(player)
