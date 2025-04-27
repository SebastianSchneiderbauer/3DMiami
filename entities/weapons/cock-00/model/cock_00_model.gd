extends CharacterBody3D

@export var firing: bool = false
var gravity := Vector3(0,-9.81,0)
var onGround := false
var pickuprange := 2
var player
var loaded = false

var weapon = Weapon.create_gun("cock-00",1,0.1,1,1,false,1,"big")

func _ready():
	SaveManager.save_data_update.connect(_on_savedata_update)
	if get_parent().name == "TBLoader":
		player = get_parent().get_node("player")
	elif get_parent().name == "player":
		player = get_parent()

func _on_savedata_update():
	var type:int = SaveManager.get_data("scaler")
	var strength:float
	$high1.material_overlay.albedo_color = SaveManager.get_data("highlightColor")
	$high1.material_overlay.albedo_color.a = 0.32
	$high2.material_overlay.albedo_color = SaveManager.get_data("highlightColor")
	$high2.material_overlay.albedo_color.a = 0.32
	$high2/OmniLight3D.light_color = SaveManager.get_data("highlightColor")

func add():
	if player and not player.pickUpable.has(self):
		player.pickUpable.append(self)
	
	$high1.show()
	$high2.show()

func remove():
	if player:
		player.pickUpable.erase(self)
	
	$high1.hide()
	$high2.hide()

func _physics_process(delta: float) -> void:
	if SaveManager.loaded and not loaded:
		loaded = true
		_on_savedata_update()
	
	if firing:
		if (global_position - player.global_position).length() < pickuprange:
			add()
		else:
			remove()
		rotate_y(0.1)
		$MeshInstance3D2.set_layer_mask_value(1,true) 
		$MeshInstance3D2.set_layer_mask_value(19,false) 
		$MeshInstance3D3.set_layer_mask_value(1,true) 
		$MeshInstance3D3.set_layer_mask_value(19,false)
		$high1.set_layer_mask_value(1,true) 
		$high1.set_layer_mask_value(19,false) 
		$high2.set_layer_mask_value(1,true) 
		$high2.set_layer_mask_value(19,false)  
		
		if is_on_ceiling() or is_on_wall():
			velocity.x = 0
			velocity.z = 0
			 
			if velocity.y > 0:
				velocity.y = 0
		elif is_on_floor():
			onGround = true
			firing = false
		else:
			velocity += gravity*delta
			if velocity.y < -9.81:
				pass#velocity.y = -9.810
		
		move_and_slide()
	elif onGround:
		$high1.material_overlay.albedo_color.a = 0.32
		$high2.material_overlay.albedo_color.a = 0.32
		if (global_position - player.global_position).length() < pickuprange:
			add()
		else:
			remove()
	else:
			remove()
