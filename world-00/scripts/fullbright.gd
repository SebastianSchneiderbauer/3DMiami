extends WorldEnvironment

func _ready():
	Console.add_command("hkglow",hk_glow,[],0,"")

var glow = false

func hk_glow():
	glow = not glow
	
	if glow: 
		#toggleLightmap(0) //completely useless piece of shit
		environment.background_energy_multiplier = 16
	else:
		#toggleLightmap(0)
		environment.background_energy_multiplier = 1
	
	

func toggleLightmap(value:int):
	var tbloader = get_parent().get_child(1)
	var toggleVariable
	
	for child in tbloader.get_children():
		if "Layer" in child.name and child is Node3D:
			child.get_child(0).set_gi_mode(value)
