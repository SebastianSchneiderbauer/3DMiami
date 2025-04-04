extends CharacterBody3D

@export var target_name: String = "Enemy"

@onready var player = get_parent().get_node("player")

var outline_width:float = 5

var selected:bool = false
var highlightMax: int = 5

const default_gravity:Vector3 = Vector3(0,-9.8,0)
var used_gravity: Vector3 = default_gravity
var gravity_changer:float = 20 #ridiculously high, bc this without deltatime would be crazy

var loaded:bool = false

func movement(delta:float):
	#increase gravity while falling
	if velocity.y < 0 and not is_on_wall():
		used_gravity.y -= gravity_changer*delta
	else:
		used_gravity = default_gravity 
	
	if not is_on_floor():
		velocity += used_gravity * delta
	
	move_and_slide()

func turnAirdashDetectionToPlayer():
	var to_player = (player.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = Transform3D().looking_at(to_player, Vector3.UP).basis
	$"air-dash-detection-area".global_transform = Transform3D(target_rotation, $"air-dash-detection-area".global_transform.origin)

func _physics_process(delta: float) -> void:
	selected = false
	var mesh_instance_3d: MeshInstance3D = $"air-dash-detection-area/MeshInstance3D"
	mesh_instance_3d.show
	movement(delta)
	turnAirdashDetectionToPlayer()

func updateOutline(_strength:float):
	var strength = _strength
	var underOneMultiplier = 1
	
	#hardcode bc fuck expandability
	if strength < 0.12:
		underOneMultiplier = 2
	
	if strength < 0.07:
		underOneMultiplier = 3
	
	if strength < 0.05:
		underOneMultiplier = 20
	
	var shader_mat := $selectHighlight.material_overlay as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter("outline_width", outline_width*strength*underOneMultiplier)

func _process(delta):
	if SaveManager.loaded and not loaded:
		loaded = true
		var type:int = SaveManager.get_data("scaler")
		var strength:float
		
		if type == 1:
			strength = SaveManager.get_data("scalerStrength")/100
		else:
			strength = get_fsr_value(SaveManager.get_data("fsrStrength"))/100
		
		updateOutline(strength)

func getDist(hitPosition: Vector3):
	var space_state = get_world_3d().direct_space_state
	
	var from = global_transform.origin
	var to = player.global_transform.origin
	from.y +=2
	to.y +=2
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # only collide with layer 1
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		return INF
	
	var midPosition := global_position
	midPosition.y += 1
	return (hitPosition - midPosition).length()

func get_fsr_value(index:int):
	match index:
		1:
			1.0
		2:
			25.0
		3:
			50.0
		4:
			66.0
		5:
			77.0
		6:
			83.0
		7:
			125.00

func _ready():
	SaveManager.save_data_update.connect(_on_savedata_update)

func _on_savedata_update():
	var type:int = SaveManager.get_data("scaler")
	var strength:float
	
	if type == 1:
		strength = SaveManager.get_data("scalerStrength")/100
	else:
		strength = get_fsr_value(SaveManager.get_data("fsrStrength"))/100
	
	updateOutline(strength)
