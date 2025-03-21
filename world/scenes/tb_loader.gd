extends TBLoader

func _ready():
	for child in get_children():
		if child is OmniLight3D:
			child.shadow_enabled = true
	
	#set everything to be sharp
	get_node("Default Layer/entity_0_geometry").mesh.surface_get_material(0).set_texture_filter(0)
	get_node("platform-00/entity_32_geometry").mesh.surface_get_material(0).set_texture_filter(0)
	#make barriers invisible
	get_node("barriers/entity_31_geometry").mesh.surface_get_material(0).set_transparency(1)
	
	
