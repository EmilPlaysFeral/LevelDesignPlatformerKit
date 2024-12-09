extends MeshInstance3D

@export var rotation_speed : float = 10.0  # Rotation speed of the wind cylinder

func _process(delta):
	# Rotate the cylinder around its Y-axis (vertical axis) to simulate wind movement
	rotate_y(rotation_speed * delta)
