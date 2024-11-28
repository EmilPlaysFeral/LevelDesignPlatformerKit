extends MeshInstance3D

var rotation_speed = 30.0  #Adjust the speed if I need

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees.y += rotation_speed * delta #Cylinder rotates around Y-axis
