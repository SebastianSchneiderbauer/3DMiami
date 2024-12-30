extends Resource

class_name Weapon

enum WeaponType {
	MELEE,
	RANGED,
	UNDEFINED
}

@export var name: String = "Abstract Weapon"
@export var weaponIndex: int = 0
@export var damage: float = 0
@export var cooldown: float = 0
@export var equipCooldown: float = 0
@export var unequipCooldown: float = 0
@export var hasAltFire: bool = false
@export var weaponType: WeaponType = WeaponType.UNDEFINED

func attack():
	pass
