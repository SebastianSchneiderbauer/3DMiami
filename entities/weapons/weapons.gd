extends Node3D

func hideall():
	for child in get_children():
		if not child is AnimationPlayer:
			child.hide()

func hideWeapon(name:String): #only used for the throwing animation
	match(name):
		"cock-00":
			$"cock-00/Rfist/Clock-00-model".hide()

func showWeapon(name:String):
	hideall()
	#$animation.play("RESET")
	
	match(name):
		"fists":
			$fists.show()
		"cock-00":
			$"cock-00".show()
			$"cock-00/Rfist/Clock-00-model".show()
