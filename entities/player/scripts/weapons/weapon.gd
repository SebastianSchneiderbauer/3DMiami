extends Node

class_name Weapon

var weaponType: int # 0 -> blunt hit, 1 -> sharp weapon, 2 -> gun

#overall
var weapon_damage:float
var weapon_name: String
var weapon_model: MeshInstance3D
var weapon_cooldown: float # millisec.
var stagger_time:float
var attack_speed_multiplier: float # eg. double a weapons firing speed (also nerf cooldown then)
var durability: int # uses untill the weapon breaks
var weight: float # how far can you yeet it
var chargeup_time:float #something like a bfg

#blunt  (eg. a club)
var crushing_power:float # can you completely bash someones head in
var knockback:float

#sharp  (eg. a katana)
var sharpness_lvl: int # some enemys may have armour with cutting resistance

#gun    (eg. a pistol)
var overheat_max:float # decread by the time when we dont fire, increased when firing
var overheat_add:float # by what the overheat max is increased by each fire
var needs_reload: bool
var mag_size: int
var mag_bullet_count: int
var projectile: MeshInstance3D # will prob be scenes and handle the projectile stuff themself

func _init(cooldown := 0.2, damage := 10.0, max_ammo := 30):
	self.cooldown = cooldown

func attack():
	print("attacking! (" + weapon_name +")")
