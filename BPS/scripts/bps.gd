extends Node3D

var done:bool = false
var max:float
var counter:float = 0
var counterpoint:float = 0.05

func _process(delta: float) -> void:
	if Input.is_action_just_released("2"):
		counter = 0
	
	counter += delta
	
	if Input.is_action_pressed("2") and max > 0 and counter > counterpoint:
		counter = 0
		var bpsScene = load("res://BPS/scene/bp.tscn")
		var BP = bpsScene.instantiate()
		BP.start = global_position
		BP.direction = -global_transform.basis.z.normalized()*RandomNumberGenerator.new().randf_range(1,2)
		BP.direction.y = 5
		BP.gravity = Vector3(0, -9.81, 0)
		BP.speedMultiplier = 1
		add_child(BP)
		
		max -= 1
		
		rotate_y(360)
	
	if not Input.is_action_pressed("2"):
		max = 5
