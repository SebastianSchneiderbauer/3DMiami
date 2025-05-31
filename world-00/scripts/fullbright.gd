extends WorldEnvironment

func _ready():
	Console.add_command("hkglow",hk_glow,[],0,"")
	
	#performence reasons
	var kiddo = load("res://BPS/scene/bps.tscn").instantiate()
	add_child(kiddo)
	kiddo.global_position = Vector3(0,0,0)
	kiddo.fire()

var glow = false

func hk_glow():
	glow = not glow
	
	if glow: 
		toggleLightmap(false)
		environment.background_energy_multiplier = 16
	else:
		toggleLightmap(true)
		environment.background_energy_multiplier = 1
	
	

func toggleLightmap(value:bool):
	var tbloader = get_parent().get_child(1)
	var childrencount = tbloader.get_child_count()
	var lightmap = tbloader.get_child(childrencount-1)
	lightmap.visible = value
