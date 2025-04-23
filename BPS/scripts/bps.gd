extends Node3D

var done:bool = false
var max:float
var counter:float = 0
var counterpoint:float = 0.05

@export var particle_count:int = 5
@export var life_time:float = INF

func fire():
	for i in range(particle_count):
		await get_tree().create_timer(0.001).timeout
		var bpsScene = load("res://BPS/scene/bp.tscn")
		var BP = bpsScene.instantiate()
		BP.start = global_position
		BP.direction = -global_transform.basis.z.normalized()*RandomNumberGenerator.new().randf_range(1,5)
		BP.direction.y = RandomNumberGenerator.new().randf_range(1,10)
		BP.gravity = Vector3(0, -9.81, 0)
		add_child(BP)
		
		rotate_y(360)
