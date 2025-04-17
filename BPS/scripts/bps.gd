extends Node3D

var done:bool = false
var max:float
var counter:float = 0
var counterpoint:float = 0.05

@export var particle_count:int = 5
@export var decal_count:int = 20

func fire():
	$"BLOOD".emitting = true
	for i in range(particle_count):
		await get_tree().create_timer(0.1).timeout
		var bpsScene = load("res://BPS/scene/bp.tscn")
		var BP = bpsScene.instantiate()
		BP.start = global_position
		BP.direction = -global_transform.basis.z.normalized()*RandomNumberGenerator.new().randf_range(1,2)
		BP.direction.y = 4
		BP.gravity = Vector3(0, -9.81, 0)
		BP.speedMultiplier = 1
		BP.decal_count_performence = decal_count
		add_child(BP)
		
		rotate_y(360)
