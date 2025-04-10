extends CharacterBody3D

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

var baseSpeed:float = 8.0
var crouchSpeed:float = baseSpeed*1.4
var speed:float = baseSpeed
const JUMP_VELOCITY:float = 6
const airDashSpeedMultiplier:float = 6

var lastVelocityY:float = 0
var storeFrames:int = 1
var storeFrameCounter:int = 0

var direction:Vector3 = Vector3(0,0,0)
var input_dir:Vector2
@onready var camera:Camera3D = $camera
var mouse_delta:Vector2 = Vector2.ZERO
var sensitivity:float = 0.1 # editable from outside

var extraVelocity:Vector3 = Vector3.ZERO # adding extra velocity like a shockwave, wallsjumps, etc.

# weapon
var weapon: Weapon = null

# sound effects
@onready var walk: AudioStreamPlayer3D = $walk
var walktimer: float = 0

@onready var jump_air = $"jump-air"
@onready var jump_wall = $"jump-wall"
@onready var jump_ground = $"jump-ground"

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
var slideDirection:Vector3 = Vector3(0,1,0)
var slideDuration:float = 0.4
var slideTimer:float = 0
var released:bool = true

# air dash
var airdashTarget:Vector3 = Vector3.ZERO
var enemyDistance:float = INF #does not track distance to the enemy, its used for enemys to store their distance to the collision point, basicly measuring if they are the closest
var airdashing:bool = false
var airjumpTriggered:bool = false
var airdashDistance:float = 0

# focus
var focused:bool = false

#basic shit
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

#movement/cam methods
func handle_mouse_look(delta:float):
	var rotation_x = -mouse_delta.y * sensitivity# * delta * 100
	var rotation_y = -mouse_delta.x * sensitivity# * delta * 100
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x + rotation_x, -90, 90)
	rotation_degrees.y += rotation_y
	mouse_delta = Vector2.ZERO
func basic_movement():
	if airdashing:
		return
	
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0
func jump_logic(delta:float):
	if airdashing:
		return
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
		jump_ground.play()
		
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
		if not is_on_wall_only():
			if jumps > 0:
				used_gravity = default_gravity
				jumps -= 1
				velocity.y = JUMP_VELOCITY
				
				if is_on_floor():
					jump_ground.play()
				else:
					jump_air.play()
		else:
			if walljumps > 0:
				used_gravity = default_gravity
				walljumps -= 1
				var wallVector: Vector3 = get_shortest_wall_vector().normalized() * wallJumpForce * (speed/10)
				velocity.y = JUMP_VELOCITY
				jump_wall.play()
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
		vaultVector = (vaultPoint - startPosition).normalized() * speed * slideDirection.length()
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
		if lastVelocityY != 0:
			camera.startShake(0.05,0.2 * scaleMultiplier(-lastVelocityY,0,0.2))
		camera.startZoom(slideDuration,10,1)
		
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
		
		slideDirection = Vector3(0,1,0)
func airDash(delta:float):
	if not focused:
		if lastInstance != null:
			lastInstance.get_node("selectHighlight").hide()
		return
	
	var smallestInstance: CharacterBody3D = null #stores the instance of the "closest"
	var smallestDistance: float = INF
	
	for hit in get_airdash_hits_from_camera():
		var area = hit.collider
		if area.name == "air-dash-detection-area":
			var distance = area.get_parent().getDist(hit.position)
			if distance < smallestDistance and distance != INF:
				smallestDistance = distance
				smallestInstance = area.get_parent()
		elif area.name == "instant-detection":
			smallestDistance = area.get_parent().getDist(hit.position)
			smallestInstance = area.get_parent()
			break
	
	if lastInstance != null:
		lastInstance.get_node("selectHighlight").hide()
	
	if smallestInstance != null:
		lastInstance = smallestInstance
		smallestInstance.get_node("selectHighlight").show()
		
		if (Input.is_action_just_pressed("mouseclick-l") or Input.is_action_just_pressed("mouseclick-r")) and not airdashing:
			airdashTarget = smallestInstance.global_position
			camera.startZoom((airdashTarget - global_position).length()/(baseSpeed*airDashSpeedMultiplier),30, -1)
			camera.startShake(0.1,0.2)
			airdashing = true
			airjumpTriggered = false
			airdashDistance = (airdashTarget - global_position).length()
		
		return
func focus(delta:float):
	focused = Input.is_action_pressed("shift")
	return
	#we could turn this on later just does not feel right + exploitable
	if focused:
		if Engine.time_scale - (Engine.time_scale/1.5)*delta*10 < 0.3 or Engine.time_scale == 0.3:
			Engine.time_scale = 0.3
		else:
			Engine.time_scale -= (Engine.time_scale/1.5)*delta*10
	else:
		if Engine.time_scale + (Engine.time_scale*2)*delta*100 > 1 or Engine.time_scale == 1:
			Engine.time_scale = 1
		else:
			Engine.time_scale += (Engine.time_scale*2)*delta*100
func move(delta:float): #custom move function for extra logic before and after calling move_and_slide()
	velocity += extraVelocity  # Apply extra force
	extraVelocity = reduce_vector_length(extraVelocity,1)
	
	if is_on_wall() and velocity.y < 0 and not Input.is_action_pressed("ctrl") and not airdashing and not vaulting:
		velocity.y = used_gravity.y/7
	
	get_node("SubViewportContainer/SubViewport/airdash").emitting = airdashing or crouched
	if airdashing:
		if ((airdashTarget - global_position).length() < 0.1*airDashSpeedMultiplier):
			camera.startShake(0.1,0.3)
			global_position.y = airdashTarget.y
			velocity.y = 0
			extraVelocity.y = 0 
			airdashing = false
			
			set_collision_mask_value(1, true)
		else:
			focused = false
			Engine.time_scale = 1
			velocity = (airdashTarget - global_position).normalized()*baseSpeed*airDashSpeedMultiplier
			
			if not airjumpTriggered:
				extraVelocity.y += 40
				airjumpTriggered = true
			
			velocity += extraVelocity
	
	if airdashing and (get_node("hitbox-uncrouched").disabled or get_node("hitbox_crouched").disabled):
		set_collision_mask_value(1, false)
	
	move_and_slide()
	
	#fix bug where we get stuck in a wall when vaulting at a strange angle, its snappy, but fuck the user its their fualt if they run into a wall like this
	var inWallDetector: RayCast3D = $inWallDetector
	inWallDetector.force_raycast_update()
	if inWallDetector.is_colliding() and not vaulting and not airdashing:
		global_position.y +=1
	
	if velocity.y != 0 or storeFrameCounter == storeFrames:
		lastVelocityY = velocity.y
		storeFrameCounter = 0
	elif velocity.y == 0:
		storeFrameCounter += 1
var lastInstance: CharacterBody3D = null


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
	var canVault2:bool = false
	var vaultPoint1:Vector3 = Vector3.ZERO
	var vaultPoint2:Vector3 = Vector3.ZERO
	
	var posi = global_position + direction*1.5
	posi.y += vault_height
	distancer.global_position = posi
	distancer.target_position.y = -1 * (vault_height + 1)
	
	posi.y += 1
	wallchecker.global_position = posi
	var transVector = global_position - posi #translate because raycasts are stupid
	wallchecker.target_position = transVector
	wallchecker.target_position.y += 1
	
	wallchecker.force_raycast_update()
	distancer.force_raycast_update()

	if distancer.is_colliding():
		vaultPoint2 = distancer.get_collision_point()
	
	canVault2 = not wallchecker.is_colliding() and (vaultPoint2.y - global_position.y) > 0.1 and (direction != Vector3.ZERO or crouched)
	
	if canVault2:
		vaultPoint = vaultPoint2
	
	return canVault2
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
	
	if Input.is_action_just_pressed("3"):
		global_position = Vector3(-24, 91.5, 27.5)
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
func get_airdash_hits_from_camera(ray_length := 100.0) -> Array:
	var from = camera.global_transform.origin
	var direction = -camera.global_transform.basis.z
	var to = from + direction * ray_length
	
	var results: Array = []
	var exclude: Array = []
	var space_state = get_world_3d().direct_space_state
	var max_hits = 32
	var step_offset = 0.01
	var current_from = from
	
	while results.size() < max_hits:
		var params := PhysicsRayQueryParameters3D.new()
		params.from = current_from
		params.to = to
		params.exclude = exclude
		params.collision_mask = 1 << 23 # TargetArea layer
		params.collide_with_areas = true
		params.collide_with_bodies = false
		
		var hit = space_state.intersect_ray(params)
		if hit.is_empty():
			break
		
		results.append(hit)
		exclude.append(hit.collider)
		current_from = hit.position + direction * step_offset
	
	return results

func play_looping_sounds(delta:float):
	#walk sound
	if direction != Vector3.ZERO and is_on_floor() and not crouched:
		var walk_ocurrancy: float = 0.27
		var walk_sound_effect: AudioStreamPlayer3D = $"walk-normal"
		walktimer += delta
		if walktimer > walk_ocurrancy:
			walk_sound_effect.play_pitched_sound()
			walktimer = 0
	else:
		walktimer = 0.27 # instant play when walking

func _physics_process(delta): # "main"
	focus(delta) #is a part that everything could use, so delay by 1 frame would be suboptimal
	basic_movement()
	jump_logic(delta)
	crouch(delta)
	vault_logic(delta)
	airDash(delta)
	debug()

	play_looping_sounds(delta)
	
	move(delta)
func _process(delta):
	handle_mouse_look(delta)
