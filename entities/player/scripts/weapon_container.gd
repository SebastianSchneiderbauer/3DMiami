extends SubViewportContainer

func _ready() -> void:
	get_child(0).world_3d = get_viewport().world_3d

@onready var camera: Camera3D = $"../camera"
@onready var container = $SubViewport/Container
@onready var player:CharacterBody3D = get_parent()
@export var weaponSwayStrength: float = 1

@onready var AW: Node3D = $SubViewport/Container/Weapons
@onready var RW: Node3D = $"SubViewport/Container/Weapons/right-Weapon"
@onready var LW: Node3D = $"SubViewport/Container/Weapons/left-Weapon"

@onready var RA: AnimationPlayer = $right_animator
@onready var LA: AnimationPlayer = $left_animator

func _process(delta: float) -> void:
	container.global_position = camera.global_position
	container.global_rotation = camera.global_rotation
	
	animateWeapons(delta)

var crouchUpdater:bool = false
var counter:float = 0
var idleCounter:float = 0
var weaponBasePosition := Vector3(0,0,0)
var LROffset = 0

func pickWeapon(w:Weapon, side:bool): # true for left and false for right:
	if side:
		pass
	else:
		pass

func f(x): # method that makes the falling/rising weapon animation
	return tanh(x * 0.5) * (-0.35 if x >= 0.0 else -0.25)

func inRange(from:float, to:float, value:float) -> bool: #from(including to(excluding)
	return value >= from and value < to

func animateWeapons(delta:float) -> void:
	#hide
	if player.crouched and not crouchUpdater:
		crouchUpdater = true
		RA.play("hide")
		LA.play("hide")
	if not player.crouched and crouchUpdater:
		crouchUpdater = false
		RA.play("show")
		LA.play("show")
	
	#jump
	counter = fmod((counter + delta), TAU) 
	
	var jumpAnimateSpeed := 4
	var rotationgoal = f(player.velocity.y)
	if player.jumps == player.maxJumps:
		rotationgoal = 0
	
	if player.is_on_floor() and player.lastVelocityY < 0: # lil bop at the end
		player.get_node("camera").startShake(0.01,0.15)
	
	if AW.rotation.x > rotationgoal:
		if AW.rotation.x - jumpAnimateSpeed * delta > rotationgoal:
			AW.rotation.x -= jumpAnimateSpeed * delta
		else:
			AW.rotation.x = rotationgoal
	else:
		if AW.rotation.x + jumpAnimateSpeed * delta < rotationgoal:
			AW.rotation.x += jumpAnimateSpeed * delta
		else:
			AW.rotation.x = rotationgoal
	
	#walk
	var hOffsetW = 0
	var vOffsetW = 0
	var reset:bool = false
	if player.direction != Vector3.ZERO and not reset and rotationgoal == 0:
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
	AW.position = weaponBasePosition + Vector3(hOffsetW/5,vOffsetW/10,0)
	
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
	AW.position += Vector3(LROffset,0,0)
	
	#idle
	var idleVOffset:float = 0
	if player.velocity == Vector3.ZERO: 
		idleCounter = fmod((idleCounter + delta), TAU) 
		idleVOffset = sin(idleCounter) * 0.05
	else:
		idleCounter = 0
	print(idleVOffset)
	AW.position += Vector3(0,idleVOffset,0)
