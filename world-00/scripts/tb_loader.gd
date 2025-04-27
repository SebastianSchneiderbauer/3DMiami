@tool
extends TBLoader

@export var make_game_ready: bool:
	set(value):
		if value and Engine.is_editor_hint():
			makeReady()
			generate_sdf_colliders()
		make_game_ready = false  # reset toggle

func makeReady():
	for child in get_children():
		if child is OmniLight3D:
			child.shadow_enabled = true
			child.set_layer_mask_value(19,true)
		elif "Layer" in child.name and child is Node3D:
			child.get_child(0).mesh.surface_get_material(0).set_texture_filter(0)
		elif "firing" in child:
			child.firing = true
			child.rotation.x = deg_to_rad(-90.0)
		else:
			print("else")

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
