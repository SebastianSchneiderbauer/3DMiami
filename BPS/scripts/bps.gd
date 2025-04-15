extends Node3D

var done:bool = false

func _process(delta: float) -> void:
	if Input.is_action_pressed("2"):
		var bpsScene = load("res://BPS/scene/bp.tscn")
		var BP = bpsScene.instantiate()
		BP.start = global_position
		BP.direction = -global_transform.basis.z.normalized()*RandomNumberGenerator.new().randf_range(0,5)
		BP.direction.y = 11
		BP.gravity = Vector3(0, -9.81, 0)
		BP.speedMultiplier = 1
		add_child(BP)
		
		rotate_y(360)
