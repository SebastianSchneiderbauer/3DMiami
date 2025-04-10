extends SubViewportContainer

func _ready() -> void:
	get_child(0).world_3d = get_viewport().world_3d

@onready var camera: Camera3D = $"../camera"
@onready var weapons = $SubViewport/Container/Weapons
@onready var container = $SubViewport/Container
@onready var player:CharacterBody3D = get_parent()
@export var weaponSwayStrength: float = 1
var weaponBasePosition := Vector3(0,0,0)
var animationWeaponPosition := Vector3(0,0,0)

func _process(delta: float) -> void:
	container.global_position = camera.global_position
	container.global_rotation = camera.global_rotation
	
	# animate weapons
	weaponSway(delta)

var counter:float = 0

func walk(do:bool, delta:float):
	var hOffset = 0
	var vOffset = 0
	var reset:bool = false
	if do and not reset:
		counter = fmod(counter + 10*delta, TAU)
		hOffset = sin(counter)
		vOffset = abs(sin(counter))
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
		
		hOffset = sin(counter)
		vOffset = abs(sin(counter))
	weapons.position = weaponBasePosition + Vector3(hOffset/5,vOffset/10,0)

func hideWeapons(do:bool, delta:float):
	var goal := -1.5
	var base := 0.0
	var hideSpeed := 10
	if do:
		if weapons.rotation.x - hideSpeed * delta > goal:
			weapons.rotation.x -= hideSpeed * delta
	else:
		if weapons.rotation.x + hideSpeed * delta < base:
			weapons.rotation.x += hideSpeed * delta
		else:
			weapons.rotation.x = 0

func weaponSway(delta:float):
	if player.vaulting or player.crouched:
		hideWeapons(true, delta)
		walk(false, delta)
	else:
		hideWeapons(false, delta)
		if player.direction != Vector3.ZERO:
			walk(true, delta)
		else:
			walk(false, delta)

func inRange(from:float, to:float, value:float) -> bool: #from(including to(excluding)
	return value >= from and value < to
