extends Resource

class_name Weapon

enum WeaponType {
	MELEE,
	RANGED,
}

var name: String = "Abstract Weapon"
var weaponIndex: int = 0
var damage: float = 0
var attackCooldown: float = 0
var equipCooldown: float = 0
var unequipCooldown: float = 0
var hasAltFire: bool = false
var weaponType: WeaponType

func attack():
	pass
