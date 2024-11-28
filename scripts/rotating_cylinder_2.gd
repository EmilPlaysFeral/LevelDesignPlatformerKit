extends StaticBody3D

var rotation_speed = 2.0  # Cylinder rotation speed (radians per second)
var push_force = 5.0      # Force applied to the player

func _process(delta):
	# Rotate the cylinder
	rotate(Vector3(0, 0, 1), rotation_speed * delta)

func _physics_process(delta):
	# Apply motion logic in _physics_process if you need it in sync with physics
	pass

# Function to calculate the tangential velocity
func get_tangential_velocity(player_position: Vector3) -> Vector3:
	# Get the cylinder's center position
	var center = global_transform.origin

	# Calculate the direction perpendicular to the rotation
	var radial_direction = (player_position - center).normalized()
	var tangential_direction = Vector3(radial_direction.z, 0, -radial_direction.x)  # 90° to radial

	# Return the tangential velocity vector
	return tangential_direction * (rotation_speed * push_force)
