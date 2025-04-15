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

func spawndecals():
	var counter: int = 7
	var bpScene = load("res://BPS/scene/decal.tscn")
	
	xp.force_raycast_update()
	xn.force_raycast_update()
	yp.force_raycast_update()
	yn.force_raycast_update()
	zp.force_raycast_update()
	zn.force_raycast_update()
	
	if xp.is_colliding():
		print("xp")
		var xpBP = bpScene.instantiate()
		
		xpBP.rotation.z = 1.5708
		add_child(xpBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.x -= 0.05
		counter+=1
	
	if xn.is_colliding():
		print("xn")
		var xnBP = bpScene.instantiate()
		
		xnBP.rotation.z = -1.5708
		add_child(xnBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.x += 0.05
		counter+=1
	
	if yp.is_colliding():
		print("yp")
		var ypBP = bpScene.instantiate()
		
		ypBP.rotation.z = 3.14159
		add_child(ypBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.y -= 0.05
		counter+=1
	
	if yn.is_colliding():
		print("yn")
		var ynBP = bpScene.instantiate()
		
		ynBP.rotation.z = 0
		add_child(ynBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.y += 0.05
		counter+=1
	
	if zp.is_colliding():
		print("zp")
		var zpBP = bpScene.instantiate()
		
		zpBP.rotation.x = -1.5708
		add_child(zpBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.z -= 0.05
		counter+=1
	
	if zn.is_colliding():
		print("zn")
		var znBP = bpScene.instantiate()
		
		znBP.rotation.x = 1.5708
		add_child(znBP)
		
		get_child(counter).global_position = get_collision_point()
		get_child(counter).global_position.z += 0.05
		counter+=1

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
		print((direction * delta).length())
		
		spawndecals()
		
		#$"particle".hide()
		set_physics_process(false)
