extends CharacterBody3D

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

var baseSpeed:float = 7.0
var crouchSpeed:float = baseSpeed*1.4
var speed:float = baseSpeed
const JUMP_VELOCITY:float = 6

var lastVelocityY:float = 0
var storeFrames:int = 1
var storeFrameCounter:int = 0

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
var vaultDirection:Vector3
var vaultSpeed:float = 10
var speedIncrease:float = 1.5
var preservedJump:bool = false

#crouch
var crouched:bool = false
var crouchStart:float = 1.6
var crouchEnd:float = 0.8
var inWallDetectorPosition:Vector3 = Vector3(0,0.5,0)
var inWallDetectorTarget:Vector3 = Vector3(0,1,0)
var slideDirection:Vector3
var slideDuration:float = 0.4
var slideTimer:float = 0
var released:bool = true

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
	#store jump inputs while vaulting
	if (vaulting or crouched) and Input.is_action_just_pressed("ui_accept"):
		if jumps > 0:
			preservedJump = true
	
	#abort if we are sliding/crouching (aka the exact same thing, reading this in a few years will be fun (: ), but only if we are over the slide duration, aka in a fucking vent where you want to go down or something
	if crouched and slideTimer < slideDuration:
		return
	
	if not vaulting and not crouched and preservedJump:
		used_gravity = default_gravity
		jumps -= 1
		velocity.y = JUMP_VELOCITY
		
		preservedJump = false
	
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
	if Input.is_action_just_pressed("ui_accept") and not crouched:
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
				# print(wallVector)
func vault_logic(delta:float):
	if vaulting:
		velocity = Vector3.ZERO
		global_position += vaultVector * delta
		
		if tranform_into_direction_vector(global_position - vaultPoint) != vaultDirection:
			vaulting = false
			jumps = maxJumps
			get_node("hitbox-uncrouched").disabled = false
			#global_position = vaultPoint
			velocity = storedVelocity
		
		vaultDirection = tranform_into_direction_vector(global_position - vaultPoint)
		
	elif is_on_wall() and can_vault():
		get_node("hitbox-uncrouched").disabled = true
		startPosition = global_position
		vaultVector = (vaultPoint - startPosition).normalized()*vaultSpeed
		vaultDirection = tranform_into_direction_vector(global_position - vaultPoint)
		storedVelocity = velocity
		vaulting = true
func crouch(delta:float): # yes, its a slide, but fuck it this is mostly the crouching animation so it counts
	var uncrouch_detector: RayCast3D = $uncrouchDetector
	uncrouch_detector.force_raycast_update()
	
	if not released and not Input.is_action_pressed("ctrl"):
		released = true
	
	if not crouched and Input.is_action_pressed("ctrl") and is_on_floor() and released:
		if direction == Vector3.ZERO: #in case no input is present, take the one we are looking in
			var foreward:Vector3 = -camera.global_transform.basis.z
			foreward.y = 0
			direction = foreward.normalized()
		
		released = false
		slideDirection = direction * scaleMultiplier(-lastVelocityY,0,0.2)
		slideTimer = 0
		crouched = true
	
	#cases in which we end the slide
	if (slideTimer > slideDuration and not uncrouch_detector.is_colliding()):
		slideTimer = 0
		crouched = false
	
	var hitbox_uncrouched: CollisionShape3D = $"hitbox-uncrouched"
	var mesh_uncrouched: MeshInstance3D = $"mesh-uncrouched"
	var eyes_uncrouched: MeshInstance3D = $"eyes-uncrouched"
	var hitbox_crouched: CollisionShape3D = $hitbox_crouched
	var mesh_crouched: MeshInstance3D = $"mesh-crouched"
	var eyes_crouched: MeshInstance3D = $"eyes-crouched"
	var camera: Camera3D = $camera
	var in_wall_detector: RayCast3D = $inWallDetector
	
	hitbox_uncrouched.disabled = crouched
	mesh_uncrouched.visible = not crouched
	eyes_uncrouched.visible = not crouched
	hitbox_crouched.disabled = not crouched
	mesh_crouched.visible = crouched
	eyes_crouched.visible = crouched
	
	if crouched:
		if not vaulting:
			slideTimer += delta
		
		speed = crouchSpeed
		in_wall_detector.position = inWallDetectorPosition*0.5
		in_wall_detector.target_position = inWallDetectorTarget*0.5
		camera.position.y -= delta*10
		
		if camera.position.y < crouchEnd:
			camera.position.y = crouchEnd
		else:
			camera.rotation.x += delta*0.8
		
		velocity.x = slideDirection.x * speed
		velocity.z = slideDirection.z * speed
		
		direction = slideDirection
	else:
		speed = baseSpeed
		in_wall_detector.position = inWallDetectorPosition
		in_wall_detector.target_position = inWallDetectorTarget
		camera.position.y += delta*10
		
		if camera.position.y > crouchStart:
			camera.position.y = crouchStart
		else:
			camera.rotation.x -= delta*0.8
func move(delta): #custom move function for extra logic before and after calling move_and_slide()
	velocity += extraVelocity  # Apply extra force
	extraVelocity = reduce_vector_length(extraVelocity,1)
	
	if is_on_wall() and velocity.y < 0 and not Input.is_action_pressed("ctrl"):
		velocity.y = used_gravity.y/7
	
	move_and_slide()
	
	#fix bug where we get stuck in a wall when vaulting at a strange angle, its snappy, but fuck the user its their fualt if they run into a wall like this
	var inWallDetector: RayCast3D = $inWallDetector
	inWallDetector.force_raycast_update()
	if inWallDetector.is_colliding() and not vaulting:
		global_position.y +=1
	
	if velocity.y != 0 or storeFrameCounter == storeFrames:
		lastVelocityY = velocity.y
		storeFrameCounter = 0
	elif velocity.y == 0:
		storeFrameCounter += 1

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
		query.collision_mask = 1  #walls on collision layer 1
		
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
func can_vault() -> bool: #dont open me, just trust me, like fr, you will regret this
	# this is the clusterfuck that is created when you just try fixing a bug by fucking around untill it works...
	var wallchecker:RayCast3D = $wallchecker
	var distancer:RayCast3D = $distancer
	var canVault1:bool = false
	var canVault2:bool = false
	var vaultPoint1:Vector3 = Vector3.ZERO
	var vaultPoint2:Vector3 = Vector3.ZERO
	
	var posi:Vector3 = global_position + direction*0.6
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

	if distancer.is_colliding():
		vaultPoint1 = distancer.get_collision_point()
	
	canVault1 = not wallchecker.is_colliding() and (vaultPoint1.y - global_position.y) > 0 and (direction != Vector3.ZERO or crouched)
	
	#second try
	
	posi = global_position + direction*1.5
	posi.y += vault_height
	distancer.global_position = posi
	distancer.target_position.y = -1 * (vault_height + 1)
	
	posi.y += 1
	wallchecker.global_position = posi
	transVector = global_position - posi #translate because raycasts are stupid
	wallchecker.target_position = transVector
	wallchecker.target_position.y += 1
	
	wallchecker.force_raycast_update()
	distancer.force_raycast_update()

	if distancer.is_colliding():
		vaultPoint2 = distancer.get_collision_point()
	
	canVault2 = not wallchecker.is_colliding() and (vaultPoint2.y - global_position.y) > 0 and (direction != Vector3.ZERO or crouched)
	
	if canVault1:
		vaultPoint = vaultPoint1
	
	if canVault2:
		vaultPoint = vaultPoint2
	
	return canVault1 or canVault2
func tranform_into_direction_vector(vector:Vector3):
	var return_value := Vector3(1,1,1)
	if(vector.x < 0):
		return_value.x = -1
	if(vector.y < 0):
		return_value.y = -1
	if(vector.z < 0):
		return_value.z = -1
	return return_value
func debug():
	if Input.is_action_just_pressed("debug1"):
		camera.position.z = +3
	
	if Input.is_action_pressed("debug2"):
		velocity.y = 5
	
	if Input.is_action_just_pressed("debug3"):
		SaveManager.reset_to_defaults()
		SaveManager.save_game()
	
	if Input.is_action_just_pressed("debug4"):
		print(SaveManager.get_all_data())
	
	if Input.is_action_just_pressed("1"):
		global_position = Vector3(-39.5, 59.5, 50)
	
	if Input.is_action_just_pressed("2"):
		global_position = Vector3(-32, 53, 53)
func scaleMultiplier(value:float, base:float, multiplier:float): #example usecase: you scale jumps height by another property, however you want the effect of the multiplication just to be half as noticable. then you use this method with multipleir 0.5
	#error case where we are <= than the base
	if value == base and base == 0:
		value = 1
	
	if value <= base:
		return 1
	
	if base == 0:
		base = 1
	
	var result:float = (value / base) * multiplier
	
	if result < base:
		result = base
	
	return result

func _physics_process(delta): # "main"
	basic_movement()
	jump_logic(delta)
	crouch(delta)
	vault_logic(delta)
	
	debug()
	
	move(delta)
func _process(delta):
	handle_mouse_look()
