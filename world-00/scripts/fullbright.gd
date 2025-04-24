extends WorldEnvironment

func _ready():
	Console.add_command("hkglow",hk_glow,[],0,"")

var glow = false

func hk_glow():
	glow = not glow
	
	if glow: 
		environment.background_energy_multiplier = 16
	else:
		environment.background_energy_multiplier = 1
