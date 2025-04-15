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
		
		#spawndecal()
		placeDecal()
		
		$"particle".hide()
		set_physics_process(false)

func placeDecal():
	var bpScene = load("res://BPS/scene/decal.tscn").instantiate()
	add_child(bpScene)
	
	var pos = get_collision_point()
	var normal = get_collision_normal()
	
	# Optional: Slight offset to avoid clipping into surface
	pos += normal * 0.01
	
	var up = Vector3.UP
	if abs(normal.dot(up)) > 0.99:
		up = Vector3.FORWARD
	
	# Make decal face into the wall (Z axis aligned to -normal)
	var basis = Basis().looking_at(-normal, up)
	
	# Optional: random rotation around the normal for variation
	var random_angle = randf_range(0, TAU)
	basis = basis.rotated(normal, random_angle)
	
	bpScene.global_transform = Transform3D(basis, pos)
