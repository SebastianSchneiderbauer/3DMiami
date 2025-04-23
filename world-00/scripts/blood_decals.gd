extends MultiMeshInstance3D

@export var max_decals := 10000
var instance_index := 0

func _ready():
	# Pre-allocate the multimesh to the max decal count
	multimesh.set_instance_count(max_decals)

func spawn_blood_decal(position: Vector3, normal: Vector3):
	# Generate an orthonormal basis that aligns -Z with the surface normal
	var z_axis := -normal.normalized()
	
	# Pick a stable tangent vector that's not colinear with the normal
	var tangent = normal.cross(Vector3.RIGHT)
	if tangent.length() < 0.01:
		tangent = normal.cross(Vector3.FORWARD)
	tangent = tangent.normalized()
	
	# Compute the orthonormal basis vectors
	var x_axis = tangent
	var y_axis := z_axis.cross(x_axis).normalized()
	
	# Construct the Basis manually
	var basis := Basis(x_axis, y_axis, z_axis)
	
	# Optional: random rotation around the normal
	basis = basis.rotated(normal, randf() * TAU)
	
	# Build the transform
	var transform := Transform3D(basis, position)
	
	# Apply transform to the next instance slot
	multimesh.set_instance_transform(instance_index, transform)
	
	# Move to the next slot, wrapping if needed
	instance_index = (instance_index + 1) % max_decals
