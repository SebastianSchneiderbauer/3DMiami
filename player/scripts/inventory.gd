extends Node

class_name Inventory

var weapon: Weapon
var lastWeapon: Weapon

func pickUp(pickedUpWeapon: Weapon): #return null/Weapon (last weapon) to maybe eject it from the inventory
	lastWeapon = weapon
	weapon = pickedUpWeapon
	return lastWeapon

func _init(startWeapon: Weapon = null):
	weapon = startWeapon
