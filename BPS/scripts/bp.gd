extends RayCast3D

@export var direction: Vector3 = Vector3.ZERO
@export var gravity: Vector3 = Vector3(0, -9.81, 0)
@export var maxDist: float = 200.0

var particle_life_time: float = 10.0
var start: Vector3
var previous_position: Vector3
var gravity_changer:float = 5

func _ready() -> void:
	global_position = start
	previous_position = global_position

func _physics_process(delta: float) -> void:
	gravity.y -= gravity_changer*delta
	particle_life_time -= delta
	if particle_life_time <= 0:
		queue_free()
	
	direction += gravity * delta
	previous_position = global_position
	target_position = direction * delta
	force_raycast_update()
	
	if not is_colliding():
		global_position += direction * delta
		var distanceToSpawner = (global_position - get_parent().global_position).length()
		
		if distanceToSpawner > maxDist:
			queue_free()
	else:
		var impact_point = get_collision_point()
		var impact_normal = get_collision_normal()
		
		get_parent().get_parent().get_child(3).spawn_blood_decal(impact_point+impact_normal*0.05, impact_normal)
		
		queue_free()
