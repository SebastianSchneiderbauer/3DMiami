extends CharacterBody3D

@export var target_name: String = "Enemy"

@onready var player = get_parent().get_node("player")

var selected:bool = false
var highlightMax: int = 5

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

func movement(delta:float):
	#increase gravity while falling
	if velocity.y < 0 and not is_on_wall():
		used_gravity.y -= gravity_changer*delta
	else:
		used_gravity = default_gravity
	
	if not is_on_floor():
		velocity += used_gravity * delta
	
	move_and_slide()

func turnAirdashDetectionToPlayer():
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = Transform3D().looking_at(to_player, Vector3.UP).basis
	$"air-dash-detection-area".global_transform = Transform3D(target_rotation, $"air-dash-detection-area".global_transform.origin)

func _physics_process(delta: float) -> void:
	selected = false
	var mesh_instance_3d: MeshInstance3D = $"air-dash-detection-area/MeshInstance3D"
	mesh_instance_3d.show
	movement(delta)
	turnAirdashDetectionToPlayer()

func getDist(hitPosition: Vector3):
	var space_state = get_world_3d().direct_space_state
	
	var from = global_transform.origin
	var to = player.global_transform.origin
	from.y +=2
	to.y +=2
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # only collide with layer 1
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		return INF
	
	var midPosition := global_position
	midPosition.y += 1
	return (hitPosition - midPosition).length()
