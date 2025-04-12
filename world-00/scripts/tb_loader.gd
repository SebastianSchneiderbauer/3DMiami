extends TBLoader

func _ready():
	for child in get_children():
		if child is OmniLight3D:
			child.shadow_enabled = true
			child.set_layer_mask_value(19,true)
	
	#set everything to be sharp
	get_node("Default Layer/entity_0_geometry").mesh.surface_get_material(0).set_texture_filter(0)
	get_node("platform-00/entity_37_geometry").mesh.surface_get_material(0).set_texture_filter(0)
	#make barriers invisible
	get_node("barriers/entity_36_geometry").mesh.surface_get_material(0).set_transparency(1)
	
	
