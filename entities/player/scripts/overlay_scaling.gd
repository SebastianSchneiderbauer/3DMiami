extends SubViewport

var base_size = Vector2(1152,648)

func _on_savedata_update():
	var type:int = SaveManager.get_data("scaler")
	var strength:float
	
	if type == 1:
		strength = SaveManager.get_data("scalerStrength")/100
	else:
		strength = get_fsr_value(SaveManager.get_data("fsrStrength"))/100
	
	scaling_3d_scale = strength

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

var loaded: bool = false

func _process(delta):
	if SaveManager.loaded and not loaded:
		loaded = true
		var type:int = SaveManager.get_data("scaler")
		var strength:float
		
		if type == 1:
			strength = SaveManager.get_data("scalerStrength")/100
		else:
			strength = get_fsr_value(SaveManager.get_data("fsrStrength"))/100
		
		scaling_3d_scale = strength
