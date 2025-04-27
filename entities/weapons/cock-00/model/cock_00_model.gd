extends CharacterBody3D

@export var firing: bool = false
var gravity := Vector3(0,-9.81,0)
var onGround := false
var pickuprange := 4

func _ready():
	SaveManager.save_data_update.connect(_on_savedata_update)

func _on_savedata_update():
	var type:int = SaveManager.get_data("scaler")
	var strength:float
	$MeshInstance3D2.material_overlay.albedo_color = SaveManager.get_data("highlightColor")
	$MeshInstance3D2.material_overlay.albedo_color.a = 0
	$MeshInstance3D3.material_overlay.albedo_color = SaveManager.get_data("highlightColor")
	$MeshInstance3D3.material_overlay.albedo_color.a = 0


func _physics_process(delta: float) -> void:
	if firing:
		rotate_y(0.1)
		$MeshInstance3D2.set_layer_mask_value(1,true) 
		$MeshInstance3D2.set_layer_mask_value(19,false) 
		$MeshInstance3D3.set_layer_mask_value(1,true) 
		$MeshInstance3D3.set_layer_mask_value(19,false) 
		
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
