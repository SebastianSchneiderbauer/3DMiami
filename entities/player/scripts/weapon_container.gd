extends SubViewportContainer

func _ready() -> void:
	get_child(0).world_3d = get_viewport().world_3d

var throwStrength:float = 50
@onready var camera: Camera3D = $"../camera"
@onready var container = $SubViewport/Container
@onready var player:CharacterBody3D = get_parent()
@export var weaponSwayStrength: float = 1

@onready var W: Node3D = $SubViewport/Container/Weapon/weapons
@onready var CW: Node3D = $"SubViewport/Container/Weapon"
@onready var blood: GPUParticles3D = $BLOOD
@onready var A: AnimationPlayer = $animator

var attackCooldownCounter:float = 0
func attack():
	if attackCooldownCounter >= player.weapon.weapon_cooldown:
		$"SubViewport/Container/Weapon/weapons/animation".stop()
		attackCooldownCounter = 0
		match(player.weapon.weapon_name):
			"fists":
				$"SubViewport/Container/Weapon/weapons/animation".play("punch")
			"cock-00":
				$"SubViewport/Container/Weapon/weapons/animation".play("pistol-1-fire")

var dropping:bool = false
func drop():
	#play animation and spawn throwable
	match(player.weapon.weapon_name):
		"fists":
			pass
		"cock-00":
			#spawn throwable
			var throwable = load("res://entities/weapons/cock-00/model/cock-00.tscn").instantiate()
			get_parent().add_child(throwable)
			throwable.top_level = true
			throwable.global_position = get_parent().global_position
			throwable.global_position.y += 1.5
			throwable.velocity = get_parent().get_node("camera").global_transform.basis.z.normalized() * -throwStrength
			throwable.firing = true
			
			#play animation
			$SubViewport/Container/Weapon/weapons.hideWeapon(player.weapon.weapon_name)
			dropping = true
			A.play("hide")
	
	#reset weapon
	player.weapon = player.baseWeapon

var picking: bool = true
func pick():
	match (player.weapon.weapon_name):
		"cock-00":
			picking = true
			A.play("hide")

func _process(delta: float) -> void:
	container.global_position = camera.global_position
	container.global_rotation = camera.global_rotation
	
	animateWeapons(delta)
	
	if not A.is_playing() and dropping:
		dropping = false
		
		$SubViewport/Container/Weapon/weapons.showWeapon(player.weapon.weapon_name)
		if player.crouched:
			print("TODO: insert slide-drop-sound")
	
	if not A.is_playing() and picking:
		picking = false
		
		#$"SubViewport/Container/Weapon/weapons/animation".play("RESET")
		
		$SubViewport/Container/Weapon/weapons.showWeapon(player.weapon.weapon_name)
		if not player.crouched:
			A.play("show")
		else:
			print("TODO: insert slide-pick-sound")
	
	attackCooldownCounter += delta

var crouchUpdater:bool = false
var counter:float = 0
var idleCounter:float = 0
var weaponBasePosition := Vector3(0, 0.641, -0.848)
var LROffset = 0

func f(x): # method that makes the falling/rising weapon animation
	return tanh(x * 0.5) * (-0.2 if x >= 0.0 else -0.1)
func inRange(from:float, to:float, value:float) -> bool: #from(including to(excluding)
	return value >= from and value < to
func animateWeapons(delta:float) -> void:
	#hide
	if (player.crouched or player.vaulting) and not crouchUpdater:
		crouchUpdater = true
		A.play("hide")
	if not (player.crouched or player.vaulting) and crouchUpdater:
		crouchUpdater = false
		A.play("show")
	
	#jump
	counter = fmod((counter + delta), TAU) 
	
	var jumpAnimateSpeed := 5
	var rotationgoal = f(player.velocity.y)
	if player.jumps == player.maxJumps or player.airdashing:
		rotationgoal = 0
	
	if CW.rotation.x > rotationgoal:
		if CW.rotation.x - jumpAnimateSpeed * delta > rotationgoal:
			CW.rotation.x -= jumpAnimateSpeed * delta
		else:
			CW.rotation.x = rotationgoal
	else:
		if CW.rotation.x + jumpAnimateSpeed * delta < rotationgoal:
			CW.rotation.x += jumpAnimateSpeed * delta
		else:
			CW.rotation.x = rotationgoal
	
	#walk
	var hOffsetW = 0
	var vOffsetW = 0
	var reset:bool = false
	if ((player.direction != Vector3.ZERO and not reset and rotationgoal == 0) or player.airdashing) and not player.crouched:
		counter = fmod(counter + 10*delta, TAU)
		hOffsetW = sin(counter)
		vOffsetW = abs(sin(counter))
	else:
		reset = true
		if inRange(0, PI/2, counter):
			if counter - 10*delta > 0:
				counter -= 10*delta
			else:
				counter = 0
				reset = false
		elif inRange(PI/2, PI, counter):
			if counter + 10*delta < PI:
				counter += 10*delta
			else:
				counter = 0
				reset = false
		elif inRange(PI,TAU-PI/2,counter):
			if counter - 10*delta > PI:
				counter -= 10*delta
			else:
				counter = 0
				reset = false
		else: # is in TAU-PI untill TAU
			if counter + 10*delta < TAU:
				counter += 10*delta
			else:
				counter = 0
				reset = false
		
		hOffsetW = sin(counter)
		vOffsetW = abs(sin(counter))
	CW.position = weaponBasePosition + Vector3(hOffsetW/5,vOffsetW/10,0)
	
	#left/right
	var LROffsetgoal = player.input_dir.x * -0.2
	var LROffsetSpeed = 3
	if LROffset > LROffsetgoal:
		if LROffset - delta * LROffsetSpeed > LROffsetgoal:
			LROffset -= delta * LROffsetSpeed 
		else:
			LROffset = LROffsetgoal
	elif LROffset < LROffsetgoal:
		if LROffset + delta * LROffsetSpeed < LROffsetgoal:
			LROffset += delta * LROffsetSpeed 
		else:
			LROffset = LROffsetgoal
	CW.position += Vector3(LROffset,0,0)
	
	#idle
	var idleVOffset:float = 0
	if player.velocity == Vector3.ZERO: 
		idleCounter = fmod((idleCounter + delta), TAU) 
		idleVOffset = sin(idleCounter) * 0.05
	else:
		idleCounter = 0
	CW.position += Vector3(0,idleVOffset,0)
