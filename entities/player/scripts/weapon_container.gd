extends SubViewportContainer

func _ready() -> void:
	get_child(0).world_3d = get_viewport().world_3d

@onready var camera: Camera3D = $"../camera"
@onready var container = $SubViewport/Container
@onready var player:CharacterBody3D = get_parent()
@export var weaponSwayStrength: float = 1

@onready var W: Node3D = $SubViewport/Container/Weapon/fists
@onready var CW: Node3D = $"SubViewport/Container/Weapon"
@onready var blood: GPUParticles3D = $BLOOD

@onready var A: AnimationPlayer = $animator

func _process(delta: float) -> void:
	container.global_position = camera.global_position
	container.global_rotation = camera.global_rotation
	
	animateWeapons(delta)
	
	var exampleGun: Weapon = Weapon.create_gun("supi",1,1,1,1,1,1,1,"Glock-00",1,1,true,1,"dontcare")
	
	if Input.is_action_just_pressed("e") and (not player.airdashing and not player.crouched and not player.vaulting):
		W.get_node("animation").play("slice")
		W.get_node("animation").stop()
		W.get_node("animation").seek(0.0, true)
		W.get_node("animation").play("slice")

var crouchUpdater:bool = false
var counter:float = 0
var idleCounter:float = 0
var weaponBasePosition := Vector3(0, 0.641, -0.848)
var LROffset = 0

func f(x): # method that makes the falling/rising weapon animation
	return tanh(x * 0.5) * (-0.35 if x >= 0.0 else -0.25)

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
