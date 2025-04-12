extends Node

class_name Weapon

var weaponType: int # 0 -> blunt hit, 1 -> sharp weapon, 2 -> gun

# overall
var weapon_damage: float
var weapon_name: String
var weapon_model: String #handels looks and animation, name of the MODEL
var weapon_cooldown: float # millisec.
var stagger_time: float
var attack_speed_multiplier: float # CHEAT eg. double a weapons firing speed (also nerf cooldown then)
var durability: int # uses untill the weapon breaks
var weight: float # how far can you yeet it
var chargeup_time: float #something like a bfg
var double_handed: bool # when picked up, both weapons are ejected

# blunt-specific
var crushing_power: float # can you completely bash someones head in
var knockback: float

# sharp-specific
var sharpness_lvl: int # some enemys may have armour with cutting resistance

# gun-specific
var overheat_max: float # decread by the time when we dont fire, increased when firing
var overheat_add: float # by what the overheat max is increased by each fire
var needs_reload: bool
var mag_size: int
var mag_bullet_count: int
var projectile: String # NAME of the projectile

static func create_blunt(
	name: String,
	damage: float,
	cooldown: float,
	stagger_time: float,
	attack_speed_multiplier: float,
	durability: int,
	weight: float,
	chargeup_time: float,
	model: Node3D,
	crushing_power: float,
	knockback: float
) -> Weapon:
	var w = Weapon.new()
	w.weaponType = 0
	w.weapon_name = name
	w.weapon_damage = damage
	w.weapon_cooldown = cooldown
	w.stagger_time = stagger_time
	w.attack_speed_multiplier = attack_speed_multiplier
	w.durability = durability
	w.weight = weight
	w.chargeup_time = chargeup_time
	w.weapon_model = model
	w.crushing_power = crushing_power
	w.knockback = knockback
	return w

static func create_sharp(
	name: String,
	damage: float,
	cooldown: float,
	stagger_time: float,
	attack_speed_multiplier: float,
	durability: int,
	weight: float,
	chargeup_time: float,
	model: Node3D,
	sharpness_lvl: int
) -> Weapon:
	var w = Weapon.new()
	w.weaponType = 1
	w.weapon_name = name
	w.weapon_damage = damage
	w.weapon_cooldown = cooldown
	w.stagger_time = stagger_time
	w.attack_speed_multiplier = attack_speed_multiplier
	w.durability = durability
	w.weight = weight
	w.chargeup_time = chargeup_time
	w.weapon_model = model
	w.sharpness_lvl = sharpness_lvl
	return w

static func create_gun(
	name: String,
	damage: float,
	cooldown: float,
	stagger_time: float,
	attack_speed_multiplier: float,
	durability: int,
	weight: float,
	chargeup_time: float,
	model: String,
	overheat_max: float,
	overheat_add: float,
	needs_reload: bool,
	mag_size: int,
	projectile: String
) -> Weapon:
	var w = Weapon.new()
	w.weaponType = 2
	w.weapon_name = name
	w.weapon_damage = damage
	w.weapon_cooldown = cooldown
	w.stagger_time = stagger_time
	w.attack_speed_multiplier = attack_speed_multiplier
	w.durability = durability
	w.weight = weight
	w.chargeup_time = chargeup_time
	w.weapon_model = model
	w.overheat_max = overheat_max
	w.overheat_add = overheat_add
	w.needs_reload = needs_reload
	w.mag_size = mag_size
	w.mag_bullet_count = mag_size
	w.projectile = projectile
	return w
