@tool
extends TBLoader

@export var generate_sdf_for_layers: bool:
	set(value):
		if value and Engine.is_editor_hint():
			generate_sdf_colliders()
		generate_sdf_for_layers = false  # reset toggle

func _ready():
	if not Engine.is_editor_hint():
		return

	for child in get_children():
		if child is OmniLight3D:
			child.shadow_enabled = true
			child.set_layer_mask_value(19, true)

	# Set everything to be sharp
	var geometry := get_node_or_null("Default Layer/entity_0_geometry")
	if geometry and geometry.mesh:
		var material = geometry.mesh.surface_get_material(0)
		if material:
			material.set_texture_filter(BaseMaterial3D.TEXTURE_FILTER_NEAREST)

func generate_sdf_colliders():
	print("✨ Generating SDF colliders...")
	
	for node in get_children():
		print(node.name)
		
		if "Layer" in node.name and node is Node3D:
			print("🧪 Processing:", node.name)
			var newNodeName := node.name + " Collision"
			# Remove old node if it exists (no condition check, just try)
			if node.has_node(newNodeName):
				var old_sdf := node.get_node(newNodeName)
				node.remove_child(old_sdf)
				old_sdf.queue_free()
				print("🗑️ Old SDF removed from:", node.name)
			
			var aabb = node.get_child(0).get_aabb()
			if aabb.size == Vector3.ZERO:
				print("⚠️ Skipping empty Layer:", node.name)
				continue
			
			# Create and insert new SDF node
			var sdf := GPUParticlesCollisionSDF3D.new()
			sdf.name = newNodeName
			sdf.transform.origin = aabb.position + aabb.size * 0.5
			sdf.scale = aabb.size
			sdf.bake_mask = 1
			
			node.add_child(sdf)
			sdf.owner = get_tree().edited_scene_root
			
			print("✅ SDF collider added to:", node.name)
