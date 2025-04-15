extends RayCast3D

@export var direction:Vector3 = Vector3(0,0,0)
@export var gravity:Vector3 = Vector3(0,-9.81,0)
@export var speedMultiplier:float = 1
var start:Vector3

@onready var xn: RayCast3D = $xn
@onready var yn: RayCast3D = $yn
@onready var yp: RayCast3D = $yp
@onready var zp: RayCast3D = $zp
@onready var zn: RayCast3D = $zn
@onready var xp: RayCast3D = $xp

func spawndecal():
	var bpScene = load("res://BPS/scene/decal.tscn")
	
	var combinedRotateVector: Vector3
	var counter: int = 0
	var combinedPositionOffset: Vector3 = get_collision_point()
	
	xp.force_raycast_update()
	xn.force_raycast_update()
	yp.force_raycast_update()
	yn.force_raycast_update()
	zp.force_raycast_update()
	zn.force_raycast_update()
	
	if xp.is_colliding():
		print("xp")
		
		combinedRotateVector.y += -deg_to_rad(90)
		#get_child(counter).global_position.x -= 0.05
		counter+=1
	
	if xn.is_colliding():
		print("xn")
		
		combinedRotateVector.y += deg_to_rad(90)
		#get_child(counter).global_position.x += 0.05
		counter+=1
	
	if yp.is_colliding():
		print("yp")
		
		combinedRotateVector.x += deg_to_rad(90)
		#get_child(counter).global_position.y -= 0.05
	
	if yn.is_colliding():
		print("yn")
		
		combinedRotateVector.x += -deg_to_rad(90)
		#get_child(counter).global_position.y += 0.05
	
	if zp.is_colliding():
		print("zp")
		
		print(combinedRotateVector.y)
		print(-deg_to_rad(90))
		if combinedRotateVector.y < 0:
			combinedRotateVector.y += -deg_to_rad(180)
		else:
			combinedRotateVector.y += deg_to_rad(180)
		
		#get_child(counter).global_position.z -= 0.05
		counter+=1
	
	if zn.is_colliding():
		print("zn")
		
		combinedRotateVector.y += 0 #not needed, but here for clarity
		#get_child(counter).global_position.z += 0.05
		counter+=1
	
	var BP = bpScene.instantiate()
	BP.rotation = combinedRotateVector
	if counter > 1:
		BP.rotation/=2
	else:
		BP.rotation.x/=2
	add_child(BP)

func _ready() -> void:
	global_position = start

func _physics_process(delta: float) -> void:
	delta *= speedMultiplier
	direction += gravity*delta
	
	target_position = direction * delta
	force_raycast_update()
	if not is_colliding():
		global_position += direction*delta
	else:
		direction *= 0.2 #sneak towards the goal
		
		for i in range(5):
			target_position = direction * delta
			force_raycast_update()
			
			if not is_colliding():
				global_position += direction*delta
		
		spawndecal()
		
		#$"particle".hide()
		set_physics_process(false)
