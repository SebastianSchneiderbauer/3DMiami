extends "res://player/scripts/weapon.gd"

class_name Pistol_00

var ammo: int = 0

@export var max_ammo: int = 0
@export var spread: float = 0

func attack():
	if ammo > 0:
		ammo -= 1

func _init(Ammo):
	ammo = Ammo
	
	if ammo > max_ammo:
		ammo = max_ammo
