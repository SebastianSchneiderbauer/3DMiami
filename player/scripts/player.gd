extends CharacterBody3D

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

var speed:float = 10.0
const JUMP_VELOCITY:float = 6


var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
@onready var camera:Camera3D = $camera
var mouse_delta:Vector2 = Vector2.ZERO
var sensitivity:float = 0.1 # editable from outside

var extraVelocity:Vector3 = Vector3.ZERO # adding extra velocity like a shockwave, wallsjumps, etc.

#jump stuff
const maxJumps: int = 2
const maxWalljumps: int = 3
var jumps: int = maxJumps
var walljumps: int = maxWalljumps
const wallJumpForce: float = -20 # negative to reverse the wallVector

#vault
@export var vault_height:float
var vaultPoint:Vector3
var vaulting: bool = false
var storedVelocity:Vector3
var startPosition:Vector3
var vaultVector:Vector3
var lastDistance:float
var vaultSpeed:float = 10
var speedIncrease:float = 1.5

#basic shit
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

#movement/cam methods
func handle_mouse_look():
	var rotation_x = -mouse_delta.y * sensitivity
	var rotation_y = -mouse_delta.x * sensitivity
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO
func basic_movement():
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
func jump_logic(delta:float):
	#increase gravity while falling
	if velocity.y < 0 and not is_on_wall():
		used_gravity.y -= gravity_changer*delta
	else:
		used_gravity = default_gravity
	
	if not is_on_floor():
		velocity += used_gravity * delta
	else:
		jumps = maxJumps
		walljumps = maxWalljumps
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept"):
		if not is_on_wall():
			if jumps > 0:
				used_gravity = default_gravity
				jumps -= 1
				velocity.y = JUMP_VELOCITY
		else:
			if walljumps > 0:
				used_gravity = default_gravity
				walljumps -= 1
				var wallVector: Vector3 = get_shortest_wall_vector().normalized() * wallJumpForce * (speed/10)
				velocity.y = JUMP_VELOCITY
				extraVelocity += wallVector
func vault_logic(delta:float):
	if vaulting:
		velocity = Vector3.ZERO
		global_position += vaultVector * delta
		
		if (global_position - vaultPoint).length() > lastDistance:
			vaulting = false
			jumps = maxJumps
			get_node("hitbox-uncrouched").disabled = false
			#global_position = vaultPoint
			velocity = storedVelocity
		
		lastDistance = (global_position - vaultPoint).length()
		
	elif is_on_wall() and can_vault():
		get_node("hitbox-uncrouched").disabled = true
		startPosition = global_position
		vaultVector = (vaultPoint - startPosition).normalized()*vaultSpeed
		lastDistance = 100 #just a high number
		storedVelocity = velocity
		vaulting = true
func move(delta): #custom move function for extra logic before and after calling move_and_slide()
	velocity += extraVelocity  # Apply extra force
	extraVelocity = reduce_vector_length(extraVelocity,1)
	
	if is_on_wall() and velocity.y < 0:
		velocity.y /= 5
	
	move_and_slide()
	
	if is_on_wall() and velocity.y < 0:
		velocity.y *= 5
	
	#fix bug where we get stuck in a wall when vaulting at a strange angle, its snappy, but fuck the user its their fualt if they run into a wall like this
	var inWallDetector: RayCast3D = $inWallDetector
	inWallDetector.force_raycast_update()
	if inWallDetector.is_colliding() and not vaulting:
		global_position.y +=1

#utility
func get_shortest_wall_vector() -> Vector3:
	var ray_count:int = 64
	var max_distance:float = 1 #too high for safety reasons
	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	
	var shortest_vector:Vector3 = Vector3.ZERO
	var shortest_distance:float = INF
	
	for i in range(ray_count):
		var angle:float = i * (TAU / ray_count)  # TAU = 2 * PI
		var direction:Vector3 = Vector3(cos(angle), 0, sin(angle)).normalized()
		var ray_target:Vector3 = origin + direction * max_distance
		
		var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		query.from = origin
		query.to = ray_target
		query.collision_mask = 2  #walls on collision layer 2
		
		var result = space_state.intersect_ray(query)
		
		if result:
			var distance = origin.distance_to(result.position)
			if distance < shortest_distance:
				shortest_distance = distance
				shortest_vector = result.position - origin
		else:
			if max_distance < shortest_distance:
				shortest_vector = direction * max_distance
	
	return shortest_vector
func reduce_vector_length(v: Vector3, amount: float) -> Vector3:
	var length = v.length()
	var new_length = max(length - amount, 0) # Prevents negative length
	return v.normalized() * new_length if length > 0 else Vector3.ZERO
func can_vault() -> bool: #dont open me, just trust me
	#retarded aah code
	var wallchecker:RayCast3D = $wallchecker
	var distancer:RayCast3D = $distancer
	
	var posi:Vector3 = global_position + direction*0.8
	posi.y += vault_height
	distancer.global_position = posi
	distancer.target_position.y = -1 * (vault_height + 1)
	
	posi.y += 1
	wallchecker.global_position = posi
	var transVector: Vector3 = global_position - posi #translate because raycasts are stupid
	wallchecker.target_position = transVector
	wallchecker.target_position.y += 1
	
	wallchecker.force_raycast_update()
	distancer.force_raycast_update()
	
	vaultPoint = global_position
	
	if distancer.is_colliding():
		vaultPoint = distancer.get_collision_point()
	
	return not wallchecker.is_colliding() and (vaultPoint.y - global_position.y) > 0 and direction != Vector3.ZERO
func debug():
	if Input.is_action_just_pressed("debug1"):
		camera.position.z = +3
	
	if Input.is_action_just_pressed("debug2"):
		print(SaveManager.get_data("fov"))
	
	if Input.is_action_just_pressed("debug3"):
		SaveManager.load_default_save_data()
		SaveManager.save_game()
	
	if Input.is_action_just_pressed("debug4"):
		print(SaveManager.get_all_data())

func _physics_process(delta): # "main"
	basic_movement()
	jump_logic(delta)
	vault_logic(delta)
	
	debug()
	
	move(delta)

func _process(delta):
	handle_mouse_look()
