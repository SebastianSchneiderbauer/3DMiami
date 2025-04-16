extends RayCast3D

@export var direction: Vector3 = Vector3.ZERO
@export var gravity: Vector3 = Vector3(0, -9.81, 0)
@export var speedMultiplier: float = 1

@export var spread_radius: float = 0.5
@export var time_offset: float = 0.1
@export var max_ray_length: float = 10.0
@export var decal_count_performence: int # 1) ultra performence 5) low 10) mid 15) high 20) ultra 25) no, thats plain wrong

var start: Vector3
var previous_position: Vector3

func _ready() -> void:
	global_position = start
	previous_position = global_position

func _physics_process(delta: float) -> void:
	delta *= speedMultiplier
	direction += gravity * delta
	
	previous_position = global_position
	
	target_position = direction * delta
	force_raycast_update()
	
	if not is_colliding():
		global_position += direction * delta
	else:
		direction *= 0.2
		for i in range(5):
			target_position = direction * delta
			force_raycast_update()
			if not is_colliding():
				global_position += direction * delta
		
		var impact_point = get_collision_point()
		var velocity = direction
		var offset_origin = global_position - (velocity * time_offset)
		
		scatter_and_place_decals(offset_origin, impact_point)
		
		$"particle".hide()
		
		#await get_tree().create_timer(1.0).timeout
		queue_free()

func scatter_and_place_decals(origin: Vector3, target: Vector3):
	for i in range(decal_count_performence):
		var offset = Vector3(
			randf_range(-spread_radius, spread_radius),
			randf_range(-spread_radius, spread_radius),
			randf_range(-spread_radius, spread_radius)
		)

		var dir = (target + offset - origin).normalized()

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(origin, origin + dir * max_ray_length)
		query.collision_mask = 1 # ONLY collide with layer 1

		var result = space_state.intersect_ray(query)

		if result and origin.distance_to(result.position) <= max_ray_length:
			spawn_decal(result.position, result.normal)

func spawn_decal(pos: Vector3, normal: Vector3):
	var bpScene = load("res://BPS/scene/decal.tscn").instantiate()
	var scaled = 1.5 - 1.5*(decal_count_performence/30.0)
	print(decal_count_performence/30.0)
	print(decal_count_performence)
	print(scaled)
	bpScene.mesh.size = Vector2(scaled,scaled)
	get_tree().current_scene.add_child(bpScene)

	pos += normal * 0.01
	var up = Vector3.UP
	if abs(normal.dot(up)) > 0.99:
		up = Vector3.FORWARD

	var basis = Basis().looking_at(-normal, up)
	var random_angle = randf_range(0, TAU)
	basis = basis.rotated(normal, random_angle)

	bpScene.global_transform = Transform3D(basis, pos)
