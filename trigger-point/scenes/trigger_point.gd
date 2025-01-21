extends Area3D

@export var turnSpeed: float
@export var bobSpeed: float
@export var bobHeight: float
@export var scaling: float
@export var glow:bool
@export var texture: String

var time = 0
var mesh: MeshInstance3D
var light: OmniLight3D
var collisionShape: CollisionShape3D
var baseposition: Vector3

func _ready() -> void:
	mesh = $MeshInstance3D
	light = $OmniLight3D
	collisionShape = $CollisionShape3D
	baseposition = position

	if texture:
		var texture_path = "res://textures/" + texture
		var loaded_texture = load(texture_path)
		if loaded_texture and loaded_texture is Texture2D:
			apply_texture_to_mesh(loaded_texture)

func _process(delta: float) -> void:
	time += delta
	scale = Vector3(1, 1, 1) * scaling
	if glow:
		light.omni_range = 1.502 * scaling
	else:
		light.omni_range = 0
	position = baseposition + Vector3(0, sin(time * bobSpeed) * bobHeight, 0)
	rotation.y += turnSpeed * delta

func apply_texture_to_mesh(texture: Texture2D) -> void:
	if not mesh.mesh:
		return

	# Ensure a unique material is created for this instance
	var new_material = StandardMaterial3D.new()
	new_material.albedo_texture = texture
	mesh.mesh = mesh.mesh.duplicate()
	mesh.mesh.surface_set_material(0, new_material)
