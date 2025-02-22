extends Node

class_name Inventory

var weapon: Weapon
var lastWeapon: Weapon = weapon

func pickUp(pickedUpWeapon: Weapon): #return null/Weapon (last weapon) to maybe eject it from the inventory
	lastWeapon = weapon
	weapon = pickedUpWeapon
	
	#debug shit
	var name: String = "nothing"
	if weapon != null:
		name = weapon.name
		print("collected: " + str(weapon.name) + " " + str(weapon.ammo) + "/" + str(weapon.maxAmmo))
	
	return lastWeapon

func _init(startWeapon: Weapon = null):
	weapon = startWeapon
