extends SubViewportContainer

func _ready() -> void:
	get_child(0).world_3d = get_viewport().world_3d
	
@onready var node_3d: Node3D = $SubViewport/Node3D
@onready var camera: Camera3D = $"../camera"

func _process(delta: float) -> void:
	node_3d.global_position = camera.global_position
	node_3d.global_rotation = camera.global_rotation
