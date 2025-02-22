extends "res://legacy/player/scripts/weapon.gd"

class_name Pistol_00

var ammo: int
var maxAmmo: int #not const in case we want something like a "no spread/unlimited ammo" powerup
var spread: float

func attack():
	if ammo > 0:
		ammo -= 1

func _init(Ammo):
	#set up base prop
	name = "test-pistol-00"
	weaponIndex = 1
	damage = 5
	attackCooldown = 0.2
	equipCooldown = 0
	unequipCooldown = 0
	hasAltFire = false
	weaponType = WeaponType.RANGED
	
	#set up pistol prop
	ammo = Ammo
	maxAmmo = 15
	spread = 1
	
	if ammo > maxAmmo:
		ammo = maxAmmo
